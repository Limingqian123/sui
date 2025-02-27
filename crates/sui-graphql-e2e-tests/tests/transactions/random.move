// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

//# init --simulator

//# create-checkpoint

//# advance-epoch --create-random-state

//# run-graphql
# Make sure the randomness state was created on the epoch boundary
{
    latestSuiSystemState {
        protocolConfigs {
            protocolVersion
            randomBeacon: featureFlag(key: "random_beacon") { value }
        }
    }

    object(address: "0x8") {
        address
        version
        asMoveObject {
            contents {
                type { repr }
                json
            }
        }
    }

    transactionBlockConnection(last: 1) {
        nodes {
            kind {
                __typename
                ... on EndOfEpochTransaction {
                    transactionConnection {
                        nodes { __typename }
                    }
                }
            }
        }
    }
}


//# set-random-state --randomness-round 1 --random-bytes SGVsbG8gU3Vp --randomness-initial-version 2
# Set the contents of the randomness object

//# create-checkpoint

//# run-graphql
{
    transactionBlockConnection(last: 1) {
        nodes {
            kind {
                __typename
                ... on RandomnessStateUpdateTransaction {
                    epoch { epochId }
                    randomnessRound
                    randomBytes
                    randomnessObjInitialSharedVersion
                }
            }
        }
    }
}
