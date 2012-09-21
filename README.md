# Rebel

Rebel is a framework for implementing [Model-View-ViewModel](http://en.wikipedia.org/wiki/Model_View_ViewModel) with AppKit.

This framework is very much a work in progress at the moment, and should be considered **alpha quality**. Breaking changes may happen often during this time.

## Reactivity

MVVM depends on having a powerful system for observation and bindings. In Rebel, this is accomplished using the [ReactiveCocoa](https://github.com/ReactiveCocoa) framework.

Rebel will also provide tools to integrate RAC more tightly with AppKit UIs, similarly to the relationship between .NET's [ReactiveUI](https://github.com/reactiveui/ReactiveUI) and Reactive Extensions frameworks.

## AppKit Additions

This framework also contains more general (not MVVM-specific) additions to fix bugs in AppKit, or just generally make it easier to use. Check out the documentation in class and category headers for more information.

## License

Rebel is released under the MIT license. See [LICENSE.md](https://github.com/github/Rebel/blob/master/LICENSE.md).
