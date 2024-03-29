[English](README.md) | **中文版（当前页面）**
# Mario-Forever-Thunder-Editor-Refactored
基于 Godot 4.2 开发的 Mario Forever 同人游戏开发模板，以**GDScript**为主要开发语言，辅以**C#/C++/Rust**来完成大批量、高复杂度的运算。
建议在使用前在本github页面上阅读`guide`文件夹内的手册以进行学习。

## 当前版本
0.1 Beta

# 安装与更新方法
## 步骤
* 点击"Code"按钮，在弹出的窗口中找到链接右侧的按钮并点击，将会将链接复制进剪贴板中。
* 使用本模板前，下载并安装Git。
* Git安装成功后，找一个文件夹并进入，在空白处右键找到"Open Git Bash here"（如果是Windows 11系统的用户，则需要多点一个“显示更多选项”后才能显示该选项），之后便会弹出命令面板。
* 在弹出的命令面板中输入以下命令:
  ```dos
  git clone <the_link_in_your_clipboard> [directory] --recursive
  ```
  由于本引擎中[模板核心为子模块](https://github.com/Thunder-Engine-Dev/Mario-Forever-Thunder-Editor-Refactored-Core-Engine)，故此处必须填入`--recursive`参数。如果不填入该参数，在克隆时就不会将引擎核心一并进行克隆，模板安装就会失败。
* 若安装后未显示任何错误，则模板安装成功
* 若需要更新引擎，可进入引擎所安装的目录内，在空白处右键打开Git Bash，输入以下命令：
  ```dos
  git submodule init --recursive
  git submodule update --recursive
  ```
  若未显示任何错误，则模板更新成功。
## 常见问题
### 在克隆的时候突然中断，弹出"fatal xxx"错误
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
Unlike previous Thunder Engine, Thunder Editor Refactor is operated based on Nodes, since they can provide clear, logical and easy-to-implement interfaces for users, particularly those who doesn't like to set abundant resources that ends up with mess, like the current situation in Thunder Engine. However, it requires you to remember which node drives which one or more, which means that the implementation of node-driven system could be a bit difficult to comprehend and needs days of hardwork to master.
## Signal-method Connection Structure
Since signals help with transmission of messages from one node to the other one(s), and due to their ability to be manually pre-connected to other nodes through the inspector, this template takes this feature into application so that a large amount of behaviors are able to turn into interfaces for other nodes by signal connections, which is couplingless and flexible.
E.g. You have an EntityBody2D that should jump when it touches the ground. In this situation, you can connect its `collided_floor` signal to its method `jump` with a certain `float` passed in in advanced signal connection panel, and when the object hits the ground, it will jump. If you don't need this feature, just remove the connection. Therefore, you don't have to write two copies of scripts to separately code these behaviors.
## Guidebooks
To help freshmen users to operate this template, in `guides` folder are placed .md files which may help and guide them what to know about this template, and how to use, code this it, which may greately reduce the difficulty of learning from zero.
## Simple Multiplayers
In Thunder Engine, developers have to overhaul the structure of the engine to implement multiplayer system, but now in Thunder Editor Refactored, it has been installed as a built-in feature! By creating at most 4 instances of the player, with their id differs from this of each other, you will have multiple players in the same level. Of course, anything has pros and cons. The multiple player system is so complex that it requires developers to code for multiplayers, and some behaviors, such as level completion and pipe warping, will behave in an incommon way. For example, if there are 3 players in the level while one of them checked the goal, then other two will disappear and the only one alive will behave walking for the completion. Another instance is that when one triggers pipe warping, the other ones will immediately teleport to this one and then start warping.  
We advice to take careful application of this feature, as it may not only lead to problems, but also performance loss due to the high cpu cost of one player.

# Credits
* ElectronicBoy(Lazy-Rabbit-2001): Major creator, coder, constructurer.
* JUE13: LibOpenMPT compiler for this template.
* Visphort: Creator of LibOpenMPT GDExtension.
* Dasasdhba: Optimization for Smooth Outline shader made by Tanders to make the effect compatible with `CanvasGroup` which makes the shader on texts possible.
* Tanders: Creator of Smooth Outline shader.
