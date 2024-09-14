//There is an instance of this SC for each admin token (PolicyId+AssetName).
//This SC produces user state tokens that should never leave this SC.
//The token AssetName is the same of adminAssetName.
//If there's a utxo with user stakeCredentials it means the user can send and receive the security.
use aiken/collection/list.{length}
use cardano/assets.{AssetName, PolicyId, flatten, quantity_of}
use cardano/transaction.{Output, OutputReference, Transaction}
use common.{is_user_allowed}
use types.{
  StateManagerDatum, StateManagerMintRedeemer, StateManagerSpendRedeemer,
}
use utils.{is_output_to_sc, must_be_signed_by_stake_credential}

validator state_manager(adminManagerHash: PolicyId, adminAssetName: AssetName) {
  mint(
    redeemer: StateManagerMintRedeemer,
    policy_id: PolicyId,
    self: Transaction,
  ) {
    let stateAssetName = adminAssetName
    expect Some(adminRefInput) =
      list.at(self.reference_inputs, redeemer.adminTokenRefInputIndex)
    expect Some(stateManagerOutput) =
      list.at(self.outputs, redeemer.stateManagerOutputIndex)
    and {
      must_be_signed_by_stake_credential(self, redeemer.adminStakeCredential),
      is_user_allowed(
        adminRefInput,
        redeemer.adminStakeCredential,
        adminManagerHash,
        adminAssetName,
      ),
      quantity_of(self.mint, policy_id, stateAssetName) == 1,
      quantity_of(stateManagerOutput.value, policy_id, stateAssetName) == 1,
      is_output_to_sc(stateManagerOutput, policy_id),
      length(flatten(stateManagerOutput.value)) <= 21,
    }
  }

  spend(
    _datumOpt: Option<StateManagerDatum>,
    redeemer: StateManagerSpendRedeemer,
    _input: OutputReference,
    self: Transaction,
  ) {
    expect Some(adminRefInput) =
      list.at(self.reference_inputs, redeemer.adminTokenRefInputIndex)
    and {
      must_be_signed_by_stake_credential(self, redeemer.adminStakeCredential),
      is_user_allowed(
        adminRefInput,
        redeemer.adminStakeCredential,
        adminManagerHash,
        adminAssetName,
      ),
    }
  }

  else(_) {
    fail
  }
}
