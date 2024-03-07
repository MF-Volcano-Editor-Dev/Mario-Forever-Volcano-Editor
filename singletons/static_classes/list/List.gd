class_name DataList

## Static class used to provide lists of data for other classes or codes.
##
## [b]Technical:[/b] Since enum is equal to [code]const Enum: Dictionary = {}[/code], you may try modify this property externally.

## Id of attack by [Attackers].[br]
enum AttackId {
	NONE,
	FORCED,
	HEAD,
	STARMAN,
	SHELL,
	FIREBALL,
	BEETROOT,
	HAMMER,
}
