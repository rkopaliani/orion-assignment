# orion-assignment

### Notes:

- IMPORTANT: I've messed up and for some reason blanked on a line about `AppKit`. I've read `AppKit`, but registered `SwiftUI`. I'm much better with `AppKit` (especially with proper constraints and animations) than with `SwiftUI`, but looks like Covid fried my brain, and I re-read the assignment only on the day of submission. It's probably a dealbreaker, but if you are curious, please check out the project and notes below.

- As an architecture, I've used a pretty standard MVVM version:
    -  Every `View` up to the most straightforward control should have an associated `ViewModel`. This approach enables pseudo-UI testing with unit tests – e.g. we don't cover how view looks, but we can cover many aspects of `View` interactions using `ViewModel`s.
    - Classes in `ViewModel`, `Model` and business logic (which I have none in this project) layers are split into `Interface` and `Impl`. It helps immensely with tests on top of obvious stuff like abstraction etc.
    - Unfortunately, `@Published` and similar attributes are not available in the protocol world afaik, forcing me to declare the `ViewModel` layer `Interfaces` as classes. It's not pretty, but SwiftUI forces my hand here a bit. With `AppKit` there is of course no such problem.
    - Architecture might seem a bit overengineered, but I use Sourcery scripts for scaffolding and code generation. 
    - Because much of the code was generated I've decided not to play around with new macros like `@Observable` to keep the code consistent. I need to update my scripts for that, but I was postponing that for a while.
- I've copied my custom utils and extensions that I use in my pet projects. Some of them are not even used in this assignment.
- SwiftLint was used during the development, but I've removed the lint phase before submission.
- Project uses one 3rd party dependency to fetch `favIcon`.
- There are no unit, UI, or other tests. I was running on a tight schedule even without tests before Covid killed my chances of making it on time. However, this architecture works beautifully with tests.
