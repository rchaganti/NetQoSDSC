ConvertFrom-StringData @'
CheckQosPolicy = Checking if the net QoS policy exists.
QoSpolicyExists = A QoS policy by name {0} exists in policy store {1}.
QoSpolicyExistsNoAction = QoS policy exists as desired. No action needed.
QoSPolicyDoesNotExist = A QoS policy by name {0} does not exist in policy store {1}.
QoSpolicyExistsWithDifferent8021 = A QoS policy by name {0} exists in policy store {1} with different 802.1 action value.
QoSpolicyExistsWithDifferentThrottleRate = A QoS policy by name {0} exists in policy store {1} with different throttle rate.
QoSpolicyExistsWithDifferentMinBandwidthWeight = A QoS policy by name {0} exists in policy store {1} with different minimum bandwidth weight.
QoSpolicyExistsWithDifferentNetDirectPort = A QoS policy by name {0} exists in policy store {1} with different net direct port. 
QoSpolicyExistsWithDifferentDSCPAction = A QoS policy by name {0} exists in policy store {1} with different DSCP action.  
QoSpolicyExistsWithDifferentPrecedence = A QoS policy by name {0} exists in policy store {1} with different precedence.
QoSpolicyExistsWithDifferentNetProfile = A QoS policy by name {0} exists in policy store {1} with different network profile.
QoSPolicyShouldNotExist = QoS policy should not exist. It will be removed.
QoSPolicyDoesNotExistNoAction = QoS policy does not exists and there is no action needed.
RemoveQoSPolicy = Removing net QoS policy.
CreateQoSPolicy = Creating net QoS policy.
SetQoSPolicy = Updating net QoS policy.
NetDirectMatchConditionAreExclusive = NetDirectPortMatchCondition and MatchCondition cannot be used together.
FCOESelected = When FCOE is the match condition MinBandwidthWeightAction, DSCPAction, and ThrottleRateActionBitsPerSecond should not be specified.
'@
