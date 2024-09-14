//There is an instance of this SC for each state_manager instance, so one for each admin token (PolicyId+AssetName).
//Each utxo has the securities owner's stake_credential.
//The user is authorized to spend or receive the security tokens only if the state_manager has an utxo with
//a valid state token issued by the issuer and with the user's stake_credential.
use aiken/collection/list.{foldl, length}
use cardano/address.{Address, Credential, Script, StakeCredential}
use cardano/assets.{AssetName, PolicyId, flatten, quantity_of}
use cardano/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction,
}
use common.{is_user_allowed}
use types.{
  LockTokens, LockedTransferDatum, Transfer, TransferManagerMintRedeemer,
  TransferManagerSpendRedeemer, TransferManagerWithdrawRedeemer,
}
use utils.{
  get_inputs_from_sc, get_outputs_with_token, get_own_hash, is_output_to_sc,
  must_be_signed_by_stake_credential,
}

validator transfer_manager(
  issuerManagerHash: PolicyId,
  issuerAssetName: AssetName,
  adminManagerHash: PolicyId,
  adminAssetName: AssetName,
  stateManagerHash: PolicyId,
  lockedTransferManagerHash: ByteArray,
) {
  mint(
    redeemer: TransferManagerMintRedeemer,
    policy_id: PolicyId,
    self: Transaction,
  ) {
    let securityAssetName = adminAssetName
    expect Some(issuerRefInput) =
      list.at(self.reference_inputs, redeemer.issuerTokenRefInputIndex)
    expect Some(transferManagerOutput) =
      list.at(self.outputs, redeemer.transferManagerOutputIndex)
    and {
      must_be_signed_by_stake_credential(self, redeemer.issuerStakeCredential),
      is_user_allowed(
        issuerRefInput,
        redeemer.issuerStakeCredential,
        issuerManagerHash,
        issuerAssetName,
      ),
      redeemer.transferAmount > 0,
      quantity_of(self.mint, policy_id, securityAssetName) == redeemer.transferAmount,
      quantity_of(transferManagerOutput.value, policy_id, securityAssetName) == redeemer.transferAmount,
      is_output_to_sc(transferManagerOutput, policy_id),
      length(flatten(transferManagerOutput.value)) <= 21,
    }
  }

  spend(
    _datumOpt: Option<Data>,
    redeemer: TransferManagerSpendRedeemer,
    input: OutputReference,
    self: Transaction,
  ) {
    let ownScriptHash = get_own_hash(input, self.inputs)
    expect Some(withdrawScript) =
      list.at(self.withdrawals, redeemer.withdrawIndex)
    when withdrawScript is {
      Pair(Script(scriptHash), _amnt) -> scriptHash == ownScriptHash
      _ -> False
    }
  }

  withdraw(
    redeemer: TransferManagerWithdrawRedeemer,
    credential: Credential,
    self: Transaction,
  ) {
    let stateAssetName = adminAssetName
    let securityAssetName = adminAssetName
    expect Script(ownScriptHash) = credential
    when redeemer is {
      Transfer(ownerStakeCredential, ownerNFTIndex, receiversNFTIndex) -> {
        expect Some(userRefInput) =
          list.at(self.reference_inputs, ownerNFTIndex)
        and {
          must_be_signed_by_stake_credential(self, ownerStakeCredential),
          validate_all_inputs(
            self.inputs,
            ownScriptHash,
            userRefInput,
            ownerStakeCredential,
            stateManagerHash,
            stateAssetName,
          ),
          validate_all_outputs(
            self.reference_inputs,
            self.outputs,
            ownScriptHash,
            securityAssetName,
            receiversNFTIndex,
            stateManagerHash,
            stateAssetName,
          ),
        }
      }
      LockTokens(
        adminStakeCredential,
        adminRefInputIndex,
        lockedTokensAmount,
        lockingOutputIndex,
        changeOutputIndex,
        lastUserStakeCredential,
      ) -> {
        expect Some(adminRefInput) =
          list.at(self.reference_inputs, adminRefInputIndex)
        //only inputs from account
        let transferManagerInputs =
          get_inputs_from_sc(self.inputs, ownScriptHash)
        let actualInputTotalTokens =
          foldl(
            transferManagerInputs,
            0,
            fn(input, result) {
              quantity_of(input.output.value, ownScriptHash, securityAssetName) + result
            },
          )
        and {
          must_be_signed_by_stake_credential(self, adminStakeCredential),
          is_user_allowed(
            adminRefInput,
            adminStakeCredential,
            adminManagerHash,
            adminAssetName,
          ),
          all_sc_inputs_from_same_user(
            transferManagerInputs,
            lastUserStakeCredential,
          ),
          validate_lock_and_change_outputs(
            self.outputs,
            ownScriptHash,
            securityAssetName,
            actualInputTotalTokens,
            lockedTokensAmount,
            lockingOutputIndex,
            changeOutputIndex,
            lockedTransferManagerHash,
            lastUserStakeCredential,
          ),
        }
      }
    }
  }

  else(_) {
    fail
  }
}

fn validate_all_inputs(
  inputs: List<Input>,
  transferManagerScriptHash: ByteArray,
  userRefInput: Input,
  userStakeCredential: StakeCredential,
  stateManagerHash: PolicyId,
  userStateAssetName: AssetName,
) {
  //only inputs from account
  let transferManagerInputs =
    get_inputs_from_sc(inputs, transferManagerScriptHash)
  and {
    //user must be allowed to transfer
    is_user_allowed(
      userRefInput,
      userStakeCredential,
      stateManagerHash,
      userStateAssetName,
    ),
    //all inputs must belong to this user
    list.all(
      transferManagerInputs,
      fn(input) {
        expect Some(inputStakeCredential) =
          input.output.address.stake_credential
        inputStakeCredential == userStakeCredential
      },
    ),
  }
}

fn validate_all_outputs(
  referenceInputs: List<Input>,
  outputs: List<Output>,
  transferManagerScriptHash: ByteArray,
  securityAssetName: AssetName,
  receiversNFTIndex: List<Int>,
  stateManagerHash: PolicyId,
  userStateAssetName: AssetName,
) {
  let outputsWithThisToken =
    get_outputs_with_token(
      outputs,
      transferManagerScriptHash,
      securityAssetName,
    )

  let outputsAndRefInputIndexes =
    list.zip(outputsWithThisToken, receiversNFTIndex)

  and {
    length(outputsWithThisToken) == length(receiversNFTIndex),
    list.all(
      outputsAndRefInputIndexes,
      fn(outputAndRefIndex) {
        let output = outputAndRefIndex.1st
        expect Some(outputStakeCredential) = output.address.stake_credential
        expect Some(userRefInput) =
          list.at(referenceInputs, outputAndRefIndex.2nd)
        and {
          is_output_to_sc(output, transferManagerScriptHash),
          is_user_allowed(
            userRefInput,
            outputStakeCredential,
            stateManagerHash,
            userStateAssetName,
          ),
          //dos protection
          length(flatten(output.value)) <= 5,
        }
      },
    ),
  }
}

fn all_sc_inputs_from_same_user(
  transferManagerInputs: List<Input>,
  userStakeCredential: StakeCredential,
) {
  list.all(
    transferManagerInputs,
    fn(input) {
      expect Some(inputStakeCredential) = input.output.address.stake_credential
      inputStakeCredential == userStakeCredential
    },
  )
}

fn validate_lock_and_change_outputs(
  outputs: List<Output>,
  transferManagerScriptHash: ByteArray,
  securityTokenAssetName: AssetName,
  actualInputTotalTokens: Int,
  lockedTokensAmount: Int,
  lockingOutputIndex: Int,
  changeOutputIndex: Int,
  lockedTransferManager: ByteArray,
  lastUserStakeCredential: StakeCredential,
) {
  let change = actualInputTotalTokens - lockedTokensAmount

  expect Some(lockingOutput) = list.at(outputs, lockingOutputIndex)
  expect InlineDatum(locking_output_datum) = lockingOutput.datum
  expect parsedLockingDatum: LockedTransferDatum = locking_output_datum

  expect Some(changeOutput) = list.at(outputs, changeOutputIndex)
  expect Some(changeOutputStakeCredential) =
    changeOutput.address.stake_credential

  let isLockingOutputValid = and {
      is_output_to_sc(lockingOutput, lockedTransferManager),
      parsedLockingDatum == LockedTransferDatum {
        ownerStakeCredential: lastUserStakeCredential,
        tranferManagerScriptHash: transferManagerScriptHash,
        tokenAssetName: securityTokenAssetName,
      },
      quantity_of(
        lockingOutput.value,
        transferManagerScriptHash,
        securityTokenAssetName,
      ) == lockedTokensAmount,
      //dos protection
      length(flatten(lockingOutput.value)) <= 5,
    }
  let isChangeOutputValid = and {
      is_output_to_sc(changeOutput, transferManagerScriptHash),
      changeOutputStakeCredential == lastUserStakeCredential,
      quantity_of(
        changeOutput.value,
        transferManagerScriptHash,
        securityTokenAssetName,
      ) == change,
      //dos protection
      length(flatten(changeOutput.value)) <= 5,
    }
  and {
    isLockingOutputValid,
    or {
      change == 0,
      and {
        change > 0,
        isChangeOutputValid,
      },
    },
  }
}
