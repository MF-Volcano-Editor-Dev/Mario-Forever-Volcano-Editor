# Mario-Forever-Volcano-Editor
A Mario Forever fangame making template based on Godot 4.3 and above, using <b>GDScript</b> as the main language, with <b>C#/C++/Rust</b> as assistant langs for high-amount and complex calculations
Before using the template, it is recommended to learn the usage in the `guide` folder on Github.
## Current Version
0.2 Beta

# How to Install and Update?
## Steps
* Click on "Code" button and click the button at the right side of the url link, which will help copy the link into your clipboard.
* Download and install Git before you clone this template.
* After the successful installation, right click in an empty folder and select "Open Git Bash here". (If the OS you are using is Windows 11, you may need an extra click on "Show more options"). Then you will see a command panel (git bash) popped.
* In the git bash panel, code these command:
  ```dos
  git clone <the_link_in_your_clipboard> [directory] --recursive
  ```
  The parameter `--recursive` is needed since there is a [submodule](https://github.com/MF-Volcano-Editor-Dev/Mario-Forever-Volcano-Editor-Core-Engine), **the kernel part of the engine**. Therefore, your engine will be cloned as failure if the parameter is missing because without this parameter, the kernel body will be ignored during being cloned.
* If there is no any error displaying on the panel, it means the cloning and installation are successful.
* If you want to update the engine, you can right click on the empty field in the folder where the engine is cloned, and open the Git Bash again and input these commands:
  ```dos
  git submodule init --recursive
  git submodule update --recursive
  ```
  If no any errors, the update is successful.
## Questions
### An error is output during the progress of downloading, saying "fatal xxx".
This is majorly because of bad network connection to the github. Network in some location to the github is not as smooth as usual, and if you encounter the similar problem, you can try:
* Recloning
* Extending the maximum of cloning buffer
* Using some tools to help with smoother connection to github
* Using shallow cloning:
  ```dos
  git clone --depth 1 <link> [directory]
  ```]
  After the successful cloning:
  ```dos
  git fetch --unshallow
  git pull
  ```]
If all of these methods cannot yet help solve the problem, please check your network connection and make sure the connection is available to the Internet.


# Why only GDScript in the template?
Since C# needs extra steps to use, to make greenhands better get to using this editor(template), we prefer GDScript first. But this doesn't mean that we have no chances to use C# in the template anymore, unless there should be an archobstacle to solve.
## GDScript coding
GDScript is known for the fastest learning and using than C# and C++. We recommended everyone who join in Godot for the first time, to code with this language so that it ensures your smooth syntax and coding process.
## C#
C# is the middle choice between GDScript and C++, providing advanced coding and running faster than GDScript, an interpreted language with dynamic typing, because of C#'s static typing and half-compiling. Also, for those who have experience on Unity or other game engines offering C#, these developers will get familiar with the Godot coding as long as they have explored the C# API in Godot.  
However, even though C# is able to interact with GDScript, inheritance from C# to GDScript and vice versa, plus from C++ GDExtension are not supported yet.
## C++, or GDExtension
Since Godot 4.0, C++ libraries can be installed in a smoother and easier way -- GDExtension, which exceeds GDNative but inherited the style. This means that every developer can now get faster access to making a C++ script/library with godot-cpp project. C++ is the fastest language among the three, and is supported to be inherited by GDScript, so if you have requirement on calculations in large amount, or to make complex logics where some calls may lag the performance, this is a better choice for developers.  
Actually, this template contains GDExtensions made for convenience and low performance cost, especially EntityBody2D, in which a heavy calculation on physics is conducted. E.g. the redefined `move_and_slide()` in this GDExtension on some old hardwares can run around 140us, but in GDScript the number could be greater, about 200 to 350.

# Highlights
## Node-driven Framework
Unlike Thunder Engine, Volcano Editor is operated based on Nodes, since they can provide clear, logical and easy-to-implement interfaces for users, particularly those who doesn't like to set abundant resources that ends up with mess, like the current situation in Thunder Engine. However, it requires you to remember which node drives which one or more, which means that the implementation of node-driven system could be a bit difficult to comprehend and needs days of hardwork to master.
## Signal-method Connection Structure
Since signals help with transmission of messages from one node to the other one(s), and due to their ability to be manually pre-connected to other nodes through the inspector, this template takes this feature into application so that a large amount of behaviors are able to turn into interfaces for other nodes by signal connections, which is couplingless and flexible.
E.g. You have an `EntityBody2D` that should jump when it touches the ground. In this situation, you can connect its `collided_floor` signal to its method `jump` with a certain `float` passed in in advanced signal connection panel, and when the object hits the ground, it will jump. If you don't need this feature, just remove the connection. Therefore, you don't have to write two copies of scripts to separately code these behaviors.
## Guidebooks
To help freshmen users to operate this template, in `guides` folder are placed .md files which may help and guide them what to know about this template, and how to use, code this it, which may greately reduce the difficulty of learning from zero.
## Simple Multiplayers
In Thunder Engine, developers have to overhaul the structure of the engine to implement multiplayer system, but now in Volcano Editor, it has been installed as a built-in feature! By creating at most 4 instances of the player, with their id differs from this of each other, you will have multiple players in the same level. Of course, anything has pros and cons. The multiple player system is so complex that it requires developers to code for multiplayers, and some behaviors, such as level completion and pipe warping, will behave in an incommon way. For example, if there are 3 players in the level while one of them checked the goal, then other two will disappear and the only one alive will behave walking for the completion. Another instance is that when one triggers pipe warping, the other ones will immediately teleport to this one and then start warping.  
We advice to take careful application of this feature, as it may not only lead to problems, but also performance loss due to the high cpu cost of one player.

# Credits
* Yukana(Lazy-Rabbit-2001): Major creator, coder, constructurer.
* JUE13: LibOpenMPT compiler for this template.
* Visphort: Creator of LibOpenMPT GDExtension.
* Dasasdhba: Optimization for Smooth Outline shader made by Tanders to make the effect compatible with `CanvasGroup` which makes the shader on texts possible.
* Tanders: Creator of Smooth Outline shader.
