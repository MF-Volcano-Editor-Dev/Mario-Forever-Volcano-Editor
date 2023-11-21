class_name Classes

## Static class storing path to certain script

#region Components
const Attacker := preload("res://objects/#components/attacking_related/scripts/attacker.gd")
const AttackReceiver := preload("res://objects/#components/attacking_related/scripts/attack_receiver.gd")
const BlockHitter := preload("res://objects/#components/block_hitter/scripts/block_hitter.gd")
const CoinsAdder := preload("res://objects/#components/player_data_adders/scripts/coins_adder.gd")
const Disappearer := preload("res://objects/#components/disappearer/scripts/disappearer.gd")
const EffectCreator := preload("res://objects/#components/effect_creator/scripts/effect_creator.gd")
const EffectPhantomCreator := preload("res://objects/#components/effect_creator/scripts/effect_phantom_creator.gd")
const EnemyAttackReceiver := preload("res://objects/#components/enemy_related/scripts/enemy_attack_receiver.gd")
const EnemyBody := preload("res://objects/#components/enemy_related/scripts/enemy_body.gd")
const HealthComponent := preload("res://objects/#components/health_component/scripts/health_component.gd")
const ItemComponent := preload("res://objects/#components/item_component/scripts/item_component.gd")
const ItemAppearing := preload("res://objects/#components/item_component/scripts/item_appearing.gd")
const LivesAdder := preload("res://objects/#components/player_data_adders/scripts/lives_adder.gd")
const Powerup := preload("res://objects/entities/bonuses/items/scripts/powerup.gd")
const PropertyUpdater := preload("res://objects/#components/property_updater/scripts/property_updater.gd")
const ScoresAdder := preload("res://objects/#components/player_data_adders/scripts/scores_adder.gd")
const SolidDetector := preload("res://objects/#components/solid_detector/scripts/solid_detector.gd")
#endregion

#region Objects
const Coin := preload("res://objects/entities/bonuses/items/scripts/coin.gd")
const HittableBlock := preload("res://objects/entities/bonuses/blocks/scripts/hittable_block.gd")
const MarioSuit2D := preload("res://objects/entities/players/mario/scripts/mario_suit.gd")
#endregion
