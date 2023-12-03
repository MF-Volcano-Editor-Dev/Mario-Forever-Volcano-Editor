class_name Level extends SceneGame

## Class used for levels
##
## When the method [method EventsManager.level_finish] is called, the level will go into the procession
## that contains two sections:[br]
## > 1st section: In this section, a finishing music will be played and the system will wait for [member finish_process_delay] seconds.
## After the delay, if there is any object in the list mentioned in [method add_object_to_wait_finish], the system will not continue
## the execution of the second section until the list is empty [br]
## > 2nd section: Before the process of this section, if [method EventsManager.level_stop_finishment] is called, then the e
