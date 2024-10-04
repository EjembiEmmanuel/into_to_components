use core::num::traits::Zero;
use core::starknet::ContractAddress;
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address
};
use intro_to_components::ownable_counter::{
    IOwnableCounterDispatcher, IOwnableCounterDispatcherTrait
};
use intro_to_components::ownable_component::ownable_component::{
    IOwnableDispatcher, IOwnableDispatcherTrait
};

const OWNER: felt252 = 'OWNER';
const BOB: felt252 = 'BOB';

fn __setup__() -> ContractAddress {
    let ownable_counter_class_hash = declare("OwnableCounter").unwrap().contract_class();
    let mut calldata: Array<felt252> = ArrayTrait::new();
    OWNER.serialize(ref calldata);

    let (contract_address, _) = ownable_counter_class_hash.deploy(@calldata).unwrap();
    contract_address
}

#[test]
fn test_initializer() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };
    let owner = ownable_comp_dispatcher.owner();
    assert(owner == OWNER.try_into().unwrap(), 'Invalid owner');
}

#[test]
fn test_transfer_ownership() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, OWNER.try_into().unwrap());
    ownable_comp_dispatcher.transfer_ownership(BOB.try_into().unwrap());

    let owner = ownable_comp_dispatcher.owner();
    assert(owner == BOB.try_into().unwrap(), 'Invalid owner');

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
fn test_renounce_ownership() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, OWNER.try_into().unwrap());
    ownable_comp_dispatcher.renounce_ownership();

    let owner = ownable_comp_dispatcher.owner();
    assert(owner == Zero::zero(), 'Ownership not renounced');

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller not owner')]
fn test_transfer_ownership_not_owner() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, BOB.try_into().unwrap());
    ownable_comp_dispatcher.transfer_ownership(OWNER.try_into().unwrap());

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller cannot be address zero')]
fn test_transfer_ownership_address_zero() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, Zero::zero());
    ownable_comp_dispatcher.transfer_ownership(OWNER.try_into().unwrap());

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller not owner')]
fn test_renounce_ownership_fail() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, BOB.try_into().unwrap());
    ownable_comp_dispatcher.renounce_ownership();

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller cannot be address zero')]
fn test_renounce_ownership_zero() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, Zero::zero());
    ownable_comp_dispatcher.renounce_ownership();

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
fn test_increase_count() {
    let ownable_counter_contract = __setup__();
    let ownable_contract_dispatcher = IOwnableCounterDispatcher {
        contract_address: ownable_counter_contract
    };

    let count = ownable_contract_dispatcher.get_count();
    assert(count == 0, 'Invalid count');

    start_cheat_caller_address(ownable_counter_contract, OWNER.try_into().unwrap());
    ownable_contract_dispatcher.increase_count();

    let count = ownable_contract_dispatcher.get_count();
    assert(count == 1, 'Invalid count');

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller not owner')]
fn test_increase_count_not_owner() {
    let ownable_counter_contract = __setup__();
    let ownable_contract_dispatcher = IOwnableCounterDispatcher {
        contract_address: ownable_counter_contract
    };

    let count = ownable_contract_dispatcher.get_count();
    assert(count == 0, 'Invalid count');

    start_cheat_caller_address(ownable_counter_contract, BOB.try_into().unwrap());
    ownable_contract_dispatcher.increase_count();

    stop_cheat_caller_address(ownable_counter_contract);
}

