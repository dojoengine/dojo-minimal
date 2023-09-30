use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IPlayerActions<TContractState> {
    fn spawn(self: @TContractState, world: IWorldDispatcher);
}

#[starknet::contract]
mod player_actions {
    use starknet::{ContractAddress, get_caller_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo_minimal::models::{Position, Vec2};
    use super::IPlayerActions;

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl PlayerActionsImpl of IPlayerActions<ContractState> {
        // 
        // NOTICE: we pass the world dispatcher as an argument to every function
        //
        fn spawn(self: @ContractState, world: IWorldDispatcher) {
            // get player address
            let player = get_caller_address();

            // get player position
            let position = get!(world, player, (Position));

            // set player position
            set!(world, (Position { player, vec: Vec2 { x: 10, y: 10 } }));
        }
    }
}
#[cfg(test)]
mod tests {
    use core::traits::Into;
    use array::{ArrayTrait};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    use dojo_minimal::models::{position};
    use dojo_minimal::models::{Position, Vec2};

    use super::{IPlayerActionsDispatcher, IPlayerActionsDispatcherTrait, player_actions};

    #[test]
    #[available_gas(30000000)]
    fn test_move() {
        let caller = starknet::contract_address_const::<0x0>();

        // components
        let mut components = array![position::TEST_CLASS_HASH,];
        // deploy world with components
        let world = spawn_test_world(components);

        // deploy systems contract
        let contract_address = deploy_contract(player_actions::TEST_CLASS_HASH, array![].span());
        let player_actions_system = IPlayerActionsDispatcher { contract_address };

        // System calls
        player_actions_system.spawn(world);

        // check position
        let position = get!(world, caller, Position);
        assert(position.vec.x == 10, 'position x is wrong');
        assert(position.vec.y == 10, 'position y is wrong');
    }
}

