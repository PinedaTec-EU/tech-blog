# tech-blog repository context

## Runner scheduling

Ordinary jobs use the existing `pinedatec` self-hosted pool, shared by
Kopernicus and Ragnarok. Do not introduce the unregistered `primary` label.
Tracking: [#4](https://github.com/PinedaTec-EU/tech-blog/issues/4).

## Job artifact cleanup

The Pages build runs direct final `always()` workspace cleanup after uploading
its artifact. This public repository cannot consume the private shared CI actions.
The deploy job consumes the uploaded artifact independently.
SDK/download caches remain outside the disposable workspace.
Tracking: [#6](https://github.com/PinedaTec-EU/tech-blog/issues/6).

Public/private action compatibility: [#8](https://github.com/PinedaTec-EU/tech-blog/issues/8).
