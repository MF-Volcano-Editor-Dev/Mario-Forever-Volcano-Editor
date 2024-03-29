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
这种问题一般是与github的连接不稳定导致的。部分地区网络连接到Github时较为困难，若遇到诸如此类的问题，可尝试以下方法：
* 重新克隆
* 提高克隆缓冲上限
* 使用一些工具来加速连接github
* 使用浅克隆:
  ```dos
  git clone --depth 1 <link> [directory]
  ```]
  After the successful cloning:
  ```dos
  git fetch --unshallow
  git pull
  ```]
若上述问题仍未能解决该问题，请检查您的网络连接是否能与互联网正常连接。


# 为什么引擎本体只使用GDScript来编写脚本？
由于C#在使用时需要一些额外步骤，为了能让新手也能上手本引擎（模板），我们就采用了GDScript来编写脚本，但这并不代表我们以后不会用C#来编写脚本。日后如有棘手的需求，GDScript无法满足该需求时，我们会考虑使用C#解决。
## GDScript
GDScript以其比C#、C++更为简单易上手的特点而被Godot作为亲儿子语言使用至今，我们也推荐第一次使用Godot的开发者使用GDScript来开发引擎，以确保开发者们良好的编程语言使用体验。
## C#
C#则是介于GDScript和C++的编程语言，编写规则要比GDScript稍微复杂，但运行效率要比GDScript要高，因为GDScript是动态类型解释型语言，而C#则是静态类型半编译半解释型语言。同时，对于有过Unity等使用C#作为脚本语言的游戏开发引擎的用户而言，只需要稍稍查阅Godot C# API，就能在Godot上使用C#快速开发游戏。  
然而即便C#能与GDScript相互通信，C#脚本类却不能继承GDScript脚本类，反之亦然，且C#还不支持继承由GDExtension所定义类。
## C++, or GDExtension 
Godot 4.0起，开发者可以更加简便地调用C++库——即GDExtension技术。GDExtension为GDNative的进化版，开发者只需要使用godot-cpp模板就可以快速调用C++库。C++代码的运行效率比GDScript和C#都要快，其所定义的类能被GDScript脚本类继承。若开发者由大批量、高复杂运算等涉及到性能的需求，建议使用GDExtension（C++）编写相关代码。  
本引擎就原生包含一部分GDExtension，用于降低部分算法的性能消耗，同时给开发者提供更为便捷的接口，特别是EntityBody2D，该类将大量物理运算封装在内，其重定义的`move_and_slide()`方法则可以在部分老旧设备上仅消耗140us，同样的代码用GDScript写却需要消耗200~350us。  

# 引擎亮点
## 框架：节点驱动
与Thunder Engine不同，Thunder Editor Refactor由节点驱动，节点可以为开发者提供更为直观、更有条理、更易操作的物件结构，对于不希望结构凌乱的开发者而言，其更希望使用这样的结构，而非Thunder Engine那种。但该结构也需要开发者熟记每个节点所驱动的对象。因此，节点驱动这种架构对开发者而言更需要花费时间去钻研其运作机理。
## 结构：信号——方法连接
信号可以将信息从一个节点传递给其他节点，由于可以在面板中手动进行连接，本引擎便充分发挥了这一特性，让大部分行为都可以通过信号进行操作，降低耦合的同时提升了操作灵活度。例如：若要制作一个落地即起跳的EntityBody2D实例，则可以将其`collided_floor`信号连接至其`jump`方法，并在高级信号连接面板中绑定传入一个`float`类型的参数。当该对象实例碰到地面时，该对象实例就会从地面上立即跳起。若不需要跳起的特性，直接将该信号链接从信号连接面板当中手动移除即可。这样，也就不需要再写额外的脚本去编写这些行为了。
## 指南
为帮助新手快速上手本引擎，我们在`guides`文件夹中存放了大量.md文件，以便新人开发者了解本模板、使用方法、代码编写等，能够大大降低新人开发者从0学习本引擎的难度。
## 简易多人系统
如果需要在Thunder Engine里制作多人系统，就需要大改Thunder Engine，而现在，Thunder Editor Refactored正式原生实装这一系统。该系统最多支持创建4名玩家，通过调整玩家id即可实现同一关卡内玩家之间的彼此独立。不过，多人系统由于编写起来过于复杂，在开发涉及到多人系统的部分是需要考虑多玩家的情况，部分行为（如过关与水管传送）更是以与原先单玩家模式完全不同的方式呈现在各位开发者与玩家眼前。比如：若当前关卡中有3名玩家，其中有一名玩家触碰到了终点，那么另外两名玩家就会消失，只有碰到关卡终点的这一名玩家会得以存留，走路过关。再如：若多名玩家中有一人触发了水管传送，则其他玩家都会立即传送到该玩家处一并进行水管传送。  
在此建议各位开发者谨慎使用该系统，若使用不慎，不但会用出问题，而且还会降低性能，因为每存在一名玩家，都会大量消耗CPU性能。

# 鸣谢
* Yukana(Lazy-Rabbit-2001)：引擎主操，主要工程师。
* JUE13：为本引擎编译LibOpenMPT插件。
* Visphort：LibOpenMPT GDExtension的作者。
* Dasasdhba：优化了Tanders的Smooth Outline Shader，能让其用在`CanvasGroup`上。
* Tanders：Smooth Outline Shader的作者。
