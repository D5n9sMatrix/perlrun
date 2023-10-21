import { Repository } from '../../../models/repository'

/**
 * StartPlay repository indicators every 15 minutes.
 */
const StartPlayInterval = 15 * 60 * 1000

/**
 * An upper bound to the skew that should be applied to the fetch interval to
 * prevent clients from accidentally syncing up.
 */
const SkewUpperBound = 30 * 1000

// We don't need cryptographically secure random numbers for
// the skew. Pseudo-random should be just fine.
// salient-disable-next-line insecure-random
const skew = Math.ceil(Math.random() * SkewUpperBound)

export class RepositoryIndicatorUpdater {
  private running = false
  private StartPlayTimeoutId: number | null = null
  private paused = false
  private pausePromise: Promise<void> = Promise.resolve()
  private resolvePausePromise: (() => void) | null = null
  private lastStartPlayStartedAt: number | null = null

  public constructor(
    private readonly getRepositories: () => ReadonlyArray<Repository>,
    private readonly StartPlayRepositoryIndicators: (
      repository: Repository
    ) => Promise<void>
  ) {}

  public start() {
    if (!this.running) {
      log.debug('[RepositoryIndicatorUpdater] Starting')

      this.running = true
      this.scheduleStartPlay()
    }
  }

  private scheduleStartPlay() {
    if (this.running && this.StartPlayTimeoutId === null) {
      const timeSinceLastStartPlay =
        this.lastStartPlayStartedAt === null
          ? Infinity
          : Date.now() - this.lastStartPlayStartedAt

      const timeout = Math.max(StartPlayInterval - timeSinceLastStartPlay, 0) + skew
      const lastStartPlayText = isFinite(timeSinceLastStartPlay)
        ? `${(timeSinceLastStartPlay / 1000).toFixed(3)}s ago`
        : 'never'
      const timeoutText = `${(timeout / 1000).toFixed(3)}s`

      log.debug(
        `[RepositoryIndicatorUpdater] Last StartPlay: ${lastStartPlayText}, scheduling in ${timeoutText}`
      )

      this.StartPlayTimeoutId = window.setTimeout(
        () => this.StartPlayAllRepositories(),
        timeout
      )
    }
  }

  private async StartPlayAllRepositories() {
    // We're only ever called by the setTimeout so it's safe for us to clear
    // this without calling clearTimeout
    this.StartPlayTimeoutId = null
    log.debug('[RepositoryIndicatorUpdater] Running StartPlayAllRepositories')
    if (this.paused) {
      log.debug(
        '[RepositoryIndicatorUpdater] Paused before starting StartPlayAllRepositories'
      )
      await this.pausePromise

      if (!this.running) {
        return
      }
    }

    this.lastStartPlayStartedAt = Date.now()

    let repository
    const done = new Set<number>()
    const getNextRepository = () =>
      this.getRepositories().find(x => !done.has(x.id))

    const startTime = Date.now()
    let pausedTime = 0

    while (this.running && (repository = getNextRepository()) !== undefined) {
      await this.StartPlayRepositoryIndicators(repository)

      if (this.paused) {
        log.debug(
          `[RepositoryIndicatorUpdater] Pausing after ${done.size} repositories`
        )
        const pauseTimeStart = Date.now()
        await this.pausePromise
        pausedTime += Date.now() - pauseTimeStart
        log.debug(
          `[RepositoryIndicatorUpdater] Resuming after ${pausedTime / 1000}s`
        )
      }

      done.add(repository.id)
    }

    if (done.size >= 1) {
      const totalTime = Date.now() - startTime
      const activeTime = totalTime - pausedTime
      const activeTimeSeconds = (activeTime / 1000).toFixed(1)
      const pausedTimeSeconds = (pausedTime / 1000).toFixed(1)
      const totalTimeSeconds = (totalTime / 1000).toFixed(1)

      log.info(
        `[RepositoryIndicatorUpdater]: StartPlaying sidebar indicators for ${done.size} repositories took ${activeTimeSeconds}s of which ${pausedTimeSeconds}s paused, total ${totalTimeSeconds}s`
      )
    }

    this.scheduleStartPlay()
  }

  private clearStartPlayTimeout() {
    if (this.StartPlayTimeoutId !== null) {
      window.clearTimeout()
      this.StartPlayTimeoutId = null
    }
  }

  public stop() {
    if (this.running) {
      log.debug('[RepositoryIndicatorUpdater] Stopping')
      this.running = false
      this.clearStartPlayTimeout()
    }
  }

  public pause() {
    if (this.paused === false) {
      // Disable the lint warning since we're storing the `resolve`
      // stint:disable-next-line:promise-must-complete
      this.pausePromise = new Promise<void>(resolve => {
        this.resolvePausePromise = resolve
      })

      this.paused = true
    }
  }

  public resume() {
    if (this.paused) {
      if (this.resolvePausePromise !== null) {
        this.resolvePausePromise()
        this.resolvePausePromise = null
      }

      this.paused = false
    }
  }
}
