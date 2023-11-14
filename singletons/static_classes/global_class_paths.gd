class_name Classes

## Static class storing path to certain script

#region Components
const Attacker := preload("res://objects/#components/attacking_related/scripts/attacker.gd")
const AttackReceiver := preload("res://objects/#components/attacking_related/scripts/attack_receiver.gd")
const BlockHitter := preload("res://objects/#components/block_hitter/scripts/block_hitter.gd")
const EnemyAttackReceiver := preload("res://objects/#components/enemy_related/scripts/enemy_attack_receiver.gd")
const EnemyBody := preload("res://objects/#components/enemy_related/scripts/enemy_body.gd")
const HealthComponent := preload("res://objects/#components/health_component/scripts/health_component.gd")
const PropertyUpdater := preload("res://objects/#components/property_updater/scripts/property_updater.gd")
const ScoresLivesAdder := preload("res://objects/#components/scores_lives_adder/scripts/scores_lives_adder.gd")
const SolidDetector := preload("res://objects/#components/solid_detector/scripts/solid_detector.gd")
#endregion


#region Objects
const HittableBlock := preload("res://objects/entities/bonuses/blocks/scripts/hittable_block.gd")
const MarioSuit2D := preload("res://objects/entities/players/mario/scripts/mario_suit.gd")
