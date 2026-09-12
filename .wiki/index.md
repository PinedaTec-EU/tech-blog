# tech-blog repository context

## Runner scheduling

Ordinary jobs use the existing `pinedatec` self-hosted pool, shared by
Kopernicus and Ragnarok. Do not introduce the unregistered `primary` label.
Tracking: [#4](https://github.com/PinedaTec-EU/tech-blog/issues/4).

## Job artifact cleanup

Direct artifact-producing jobs register shared owned temporary storage before
setup and run final `always()` cleanup after publishing or consuming outputs.
SDK/download caches remain outside the disposable workspace.
Tracking: [#6](https://github.com/PinedaTec-EU/tech-blog/issues/6).
