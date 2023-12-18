# Mario-Forever-Thunder-Editor-Refactored
A Mario Forever fangame making template based on Godot 4.2 and above, using <b>GDScript</b> as the main language, with <b>C#/C++/Rust</b> as assistant langs for high-amount and complex calculations

## Why only GDScript in the template?
Since C# needs extra steps to use, to make greenhands better get to using this editor(template), we prefer GDScript first. But this doesn't mean that we have no chances to use C# in the template anymore, unless there should be an archobstacle to solve.
### GDScript coding
GDScript is known for the fastest learning and using than C# and C++. We recommended everyone who join in Godot for the first time, to code with this language so that it ensures your smooth syntax and coding process.
### C#
C# is the middle choice between GDScript and C++, providing advanced coding and running faster than GDScript, an interpreted language with dynamic typing, because of C#'s static typing and half-compiling. Also, for those who have experience on Unity or other game engines offering C#, these developers will get familiar with the Godot coding as long as they have explored the C# API in Godot.  
However, even though C# is able to interact with GDScript, inheritance from C# to GDScript and vice versa, and from C++ GDExtension are not supported yet.
### C++, or GDExtension
Since Godot 4.0, C++ libraries can be installed in a smoother and easier way -- GDExtension, which exceeds GDNative but inherited the style. This means that every developer can now get faster access to making a C++ script/library with godot-cpp project. C++ is the fastest language among the three, and is supported to be inherited by GDScript, so if you have requirement on calculations in large amount, or to make complex logics where some calls may lag the performance, this is a better choice for developers.  
Actually, this template contains GDExtensions made for convenience and low performance cost, especially EntityBody2D, in which a heavy calculation on physics is conducted. E.g. the redefined `move_and_slide()` in this GDExtension on some old hardwares can run around 140us, but in GDScript the number could be greater, about 200 to 350.

# Credits
* ElectronicBoy(Lazy-Rabbit-2001): Major creator, coder, constructurer.
* JUE13: LibOpenMPT compiler for this template.
* Visphort: Creator of LibOpenMPT GDExtension.
* Dasasdhba: Optimization for Smooth Outline shader made by Tanders to make the effect compatible with `CanvasGroup` which makes the shader on texts possible.
* Tanders: Creator of Smooth Outline shader.
