CREATE FOREIGN TABLE NODE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__configSource json OPTIONS(parser_format 'asJsonPretty'),
    spec__externalID string,
    spec__podCIDR string,
    spec__podCIDRs string,
    spec__providerID string,
    spec__unschedulable boolean,
    spec__additionalProperties json OPTIONS(parser_format 'asJsonPretty'),

    status__addresses json OPTIONS(parser_format 'asJsonPretty'),
    status__allocatable json OPTIONS(parser_format 'asJsonPretty'),
    status__capacity json OPTIONS(parser_format 'asJsonPretty'),
    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__config json OPTIONS(parser_format 'asJsonPretty'),
    status__daemonEndpoints json OPTIONS(parser_format 'asJsonPretty'),
    status__images json OPTIONS(parser_format 'asJsonPretty'),
    status__nodeInfo json OPTIONS(parser_format 'asJsonPretty'),
    status__phase string,
    status__volumesAttached json OPTIONS(parser_format 'asJsonPretty'),
    status__volumesInUse json,
    status__additionalProperties json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};node');

CREATE FOREIGN TABLE NODE_CONDITIONS
(
    clusterName string OPTIONS(val_variable 'cluster_name'),
    clusterUrl string OPTIONS(val_constant '{{ schema.properties.kubernetes_api_url }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),

    lastTransitionTime timestamp,
    lastUpdateTime timestamp,
    message string,
    reason string,
    status string,
    type string
)
OPTIONS(updatable false,
    synthetic_parent '{{ schema.name }}.NODE',
    synthetic_path 'status__conditions',
    tags 'kubernetes;{{ schema.properties.cluster_name }};node;conditions');


CREATE FOREIGN TABLE NAMESPACE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),
    status__phase string,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),
    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};namespace');

CREATE FOREIGN TABLE POD
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__activeDeadlineSeconds long,
    spec__affinity json,
    spec__containers json OPTIONS(parser_format 'asJsonPretty'),
    spec__nodeName string,
    spec__restartPolicy string,
    spec__tolerations json OPTIONS(parser_format 'asJsonPretty'),
    spec__volumes json OPTIONS(parser_format 'asJsonPretty'),
    spec__additionalProperties json OPTIONS(parser_format 'asJsonPretty'),

    status__message string,
    status__nominatedNodeName string,
    status__phase string,
    status__podIP string,
    status__reason string,
    status__startTime timestamp,
    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__containerStatuses json OPTIONS(parser_format 'asJsonPretty'),
    status__initContainerStatuses json OPTIONS(parser_format 'asJsonPretty'),
    status__ephemeralContainerStatuses json OPTIONS(parser_format 'asJsonPretty'),
    status__resourceClaimStatuses json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),
    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};pod');

CREATE FOREIGN TABLE POD_CONTAINER
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),
    metadata__labels json OPTIONS(synthetic_type 'parent'),
    pod_identifier string NOT NULL OPTIONS(synthetic_type 'parent', synthetic_parent_field 'identifier'),

    image string NOT NULL,
    name string NOT NULL,
    command json,
    volumeMounts json,
    resources__requests json,
    resources__limits json,
    UNIQUE(metadata__namespace, metadata__name, name)
)
  OPTIONS(updatable true,
        synthetic_parent '{{ schema.name }}.POD',
        synthetic_path 'spec__containers',
        synthetic_allow_bulk_insert false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};pod;container');

CREATE FOREIGN TABLE POD_STATUS_CONDITION
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),
    metadata__labels json OPTIONS(synthetic_type 'parent'),
    pod_identifier string NOT NULL OPTIONS(synthetic_type 'parent', synthetic_parent_field 'identifier'),

    lastTransitionTime timestamp,
    status string,
    type string

)
OPTIONS(updatable false,
        synthetic_parent '{{ schema.name }}.POD',
        synthetic_path 'status__conditions',
        synthetic_allow_bulk_insert false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};pod;status');

CREATE FOREIGN TABLE POD_CONTAINER_VOLS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),
    metadata__labels json OPTIONS(synthetic_type 'parent'),
    containerName string OPTIONS(synthetic_type 'parent_array_key', synthetic_parent_field 'name'),
    containerImage string OPTIONS(synthetic_type 'parent_array_key', synthetic_parent_field 'image'),
    pod_identifier string NOT NULL OPTIONS(synthetic_type 'parent', synthetic_parent_field 'identifier'),

    mountPath string NOT NULL,
    name string NOT NULL,
    readOnly boolean,
    identifier string OPTIONS(val_pk 'pod_identifier+containerName+name'),
    PRIMARY KEY(identifier),
    UNIQUE(metadata__namespace, metadata__name, containerName, name)
)
  OPTIONS(updatable true,
        synthetic_parent '{{ schema.name }}.POD_CONTAINER',
        synthetic_path 'volumeMounts',
        synthetic_allow_bulk_insert false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};pod;container;vols');

CREATE FOREIGN TABLE POD_CONTAINER_STATUS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),
    metadata__labels json OPTIONS(synthetic_type 'parent'),
    pod_identifier string NOT NULL OPTIONS(synthetic_type 'parent', synthetic_parent_field 'identifier'),

    name string,
    ready boolean,
    started boolean,
    restartCount integer,
    allocatedResources json OPTIONS(parser_format 'asJsonPretty'),
    containerID string,
    image string,
    imageID string,
    lastState json OPTIONS(parser_format 'asJsonPretty'),
    state json OPTIONS(parser_format 'asJsonPretty'),
    resources json OPTIONS(parser_format 'asJsonPretty'),

    identifier string OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name+name' ),
    PRIMARY KEY(identifier)
)
OPTIONS(updatable false,
        synthetic_parent '{{ schema.name }}.POD',
        synthetic_path 'status__containerStatuses',
        synthetic_allow_bulk_insert false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};pod;container;status');

CREATE FOREIGN TABLE POD_EPHEMERAL_CONTAINER_STATUS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),
    metadata__labels json OPTIONS(synthetic_type 'parent'),
    pod_identifier string NOT NULL OPTIONS(synthetic_type 'parent', synthetic_parent_field 'identifier'),

    name string,
    ready boolean,
    started boolean,
    restartCount integer,
    allocatedResources json OPTIONS(parser_format 'asJsonPretty'),
    containerID string,
    image string,
    imageID string,
    lastState json OPTIONS(parser_format 'asJsonPretty'),
    state json OPTIONS(parser_format 'asJsonPretty'),
    resources json OPTIONS(parser_format 'asJsonPretty'),

    identifier string OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name+name' ),
    PRIMARY KEY(identifier)
)
OPTIONS(updatable false,
        synthetic_parent '{{ schema.name }}.POD',
        synthetic_path 'status__ephemeralContainerStatuses',
        synthetic_allow_bulk_insert false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};pod;container;status;ephemeral');

CREATE FOREIGN TABLE POD_INIT_CONTAINER_STATUS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),
    metadata__labels json OPTIONS(synthetic_type 'parent'),
    pod_identifier string NOT NULL OPTIONS(synthetic_type 'parent', synthetic_parent_field 'identifier'),

    name string,
    ready boolean,
    started boolean,
    restartCount integer,
    allocatedResources json OPTIONS(parser_format 'asJsonPretty'),
    containerID string,
    image string,
    imageID string,
    lastState json OPTIONS(parser_format 'asJsonPretty'),
    state json OPTIONS(parser_format 'asJsonPretty'),
    resources json OPTIONS(parser_format 'asJsonPretty'),

    identifier string OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name+name' ),
    PRIMARY KEY(identifier)
)
OPTIONS(updatable false,
        synthetic_parent '{{ schema.name }}.POD',
        synthetic_path 'status__initContainerStatuses',
        synthetic_allow_bulk_insert false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};pod;container;status;init');


CREATE FOREIGN TABLE DEPLOYMENT
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__uid string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),
    spec__template__spec__containers json OPTIONS(parser_format 'asJsonPretty'),
    spec__selector__matchLabels json OPTIONS(parser_format 'asJsonPretty'),
    spec__template__metadata__labels json OPTIONS(parser_format 'asJsonPretty'),
    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__availableReplicas integer,
    status__readyReplicas integer,
    status__replicas integer,
    status__updatedReplicas integer,
    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),
    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};deployment');

CREATE FOREIGN TABLE DEPLOYMENT_CONDITIONS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),
    metadata__uid string OPTIONS(synthetic_type 'parent'),

    lastTransitionTime timestamp,
    lastUpdateTime timestamp,
    message string,
    reason string,
    status string,
    type string
)
  OPTIONS(updatable false,
        synthetic_parent '{{ schema.name }}.DEPLOYMENT',
        synthetic_path 'status__conditions',
        tags 'kubernetes;{{ schema.properties.cluster_name }};deployment;conditions');

CREATE FOREIGN TABLE DEPLOYMENT_CONTAINER
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),
    metadata__labels string OPTIONS(updatable false, synthetic_type 'parent'),
    metadata__uid string OPTIONS(synthetic_type 'parent'),

    image string NOT NULL,
    name string NOT NULL,
    command json,
    volumeMounts json,
    identifier string OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name+name' ),
    PRIMARY KEY(identifier),
    UNIQUE(metadata__namespace, metadata__name, name)
)
  OPTIONS(updatable true,
        synthetic_parent '{{ schema.name }}.DEPLOYMENT',
        synthetic_path 'spec__template__spec__containers',
        synthetic_allow_bulk_insert false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};deployment;container');

CREATE FOREIGN TABLE DEPLOYMENT_CONTAINER_VOLS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string NOT NULL OPTIONS(synthetic_type 'parent'),
    metadata__namespace string OPTIONS(synthetic_type 'parent'),
    metadata__labels string OPTIONS(synthetic_type 'parent'),
    metadata__uid string OPTIONS(synthetic_type 'parent'),
    containerName string OPTIONS(synthetic_type 'parent_array_key', synthetic_parent_field 'name'),
    containerImage string OPTIONS(synthetic_type 'parent_array_key', synthetic_parent_field 'image'),

    mountPath string NOT NULL,
    name string NOT NULL,
    readOnly boolean,
    identifier string OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name+containerName+name' ),
    PRIMARY KEY(identifier),
    UNIQUE(metadata__namespace, metadata__name, containerName, name)
)
  OPTIONS(updatable true,
        synthetic_parent '{{ schema.name }}.DEPLOYMENT_CONTAINER',
        synthetic_path 'volumeMounts',
        synthetic_allow_bulk_insert false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};deployment;container;vols');

CREATE FOREIGN TABLE PERSISTENT_VOLUME
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__accessModes json,
    spec__azureDisk json OPTIONS(parser_format 'asJsonPretty'),
    spec__azureFile json OPTIONS(parser_format 'asJsonPretty'),
    spec__capacity json OPTIONS(parser_format 'asJsonPretty'),
    spec__csi json OPTIONS(parser_format 'asJsonPretty'),
    spec__hostPath json OPTIONS(parser_format 'asJsonPretty'),
    spec__local json OPTIONS(parser_format 'asJsonPretty'),
    spec__nodeAffinity json OPTIONS(parser_format 'asJsonPretty'),
    spec__persistentVolumeReclaimPolicy string,
    spec__storageClassName string,
    spec__volumeAttributesClassName string,
    spec__volumeMode string,
    spec__additionalProperties json OPTIONS(parser_format 'asJsonPretty'),

    status__lastPhaseTransitionTime timestamp,
    status__message string,
    status__phase string,
    status__reason string,
    status__additionalProperties json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),
    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};pv');


CREATE FOREIGN TABLE PERSISTENT_VOLUME_CLAIM
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__accessModes json OPTIONS(parser_format 'asJsonPretty'),
    spec__dataSource json OPTIONS(parser_format 'asJsonPretty'),
    spec__dataSourceRef json OPTIONS(parser_format 'asJsonPretty'),
    spec__resources json OPTIONS(parser_format 'asJsonPretty'),
    spec__selector json OPTIONS(parser_format 'asJsonPretty'),
    spec__storageClassName string,
    spec__volumeAttributesClassName string,
    spec__volumeMode string,
    spec__volumeName string,

    status__accessModes json OPTIONS(parser_format 'asJsonPretty'),
    status__allocatedResourceStatuses json OPTIONS(parser_format 'asJsonPretty'),
    status__allocatedResources json OPTIONS(parser_format 'asJsonPretty'),
    status__capacity json OPTIONS(parser_format 'asJsonPretty'),
    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__currentVolumeAttributesClassName string,
    status__modifyVolumeStatus json OPTIONS(parser_format 'asJsonPretty'),
    status__phase string,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),
    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};pvc');


CREATE FOREIGN TABLE STATEFULSET
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__minReadySeconds integer,
    spec__ordinals json OPTIONS(parser_format 'asJsonPretty'),
    spec__persistentVolumeClaimRetentionPolicy json OPTIONS(parser_format 'asJsonPretty'),
    spec__podManagementPolicy string,
    spec__replicas integer,
    spec__revisionHistoryLimit integer,
    spec__serviceName string,
    spec__selector json OPTIONS(parser_format 'asJsonPretty'),
    spec__template json OPTIONS(parser_format 'asJsonPretty'),
    spec__updateStrategy json OPTIONS(parser_format 'asJsonPretty'),
    spec__volumeClaimTemplates json OPTIONS(parser_format 'asJsonPretty'),

    status__availableReplicas integer,
    status__collisionCount integer,
    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__currentReplicas integer,
    status__currentRevision string,
    status__observedGeneration long,
    status__readyReplicas integer,
    status__replicas integer,
    status__updateRevision string,
    status__updatedReplicas integer,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};statefulset');

CREATE FOREIGN TABLE SERVICE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__clusterIP string,
    spec__clusterIPs json,
    spec__externalIPs json,
    spec__externalName string,
    spec__healthCheckNodePort integer,
    spec__loadBalancerClass string,
    spec__loadBalancerIP string,
    spec__ports json OPTIONS(parser_format 'asJsonPretty'),
    spec__selector json OPTIONS(parser_format 'asJsonPretty'),
    spec__type string,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};service');

CREATE FOREIGN TABLE NETWORK_INGRESS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__backend json OPTIONS(parser_format 'asJsonPretty'),
    spec__ingressClassName string,
    spec__rules json OPTIONS(parser_format 'asJsonPretty'),
    spec__tls json OPTIONS(parser_format 'asJsonPretty'),

    status__loadBalancer json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};network;ingress');

CREATE FOREIGN TABLE NETWORK_POLICY
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__egress json OPTIONS(parser_format 'asJsonPretty'),
    spec__ingress json OPTIONS(parser_format 'asJsonPretty'),
    spec__podSelector json OPTIONS(parser_format 'asJsonPretty'),
    spec__policyTypes json,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};network;policy');

CREATE FOREIGN TABLE DAEMONSET
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__minReadySeconds integer,
    spec__revisionHistoryLimit integer,
    spec__selector json OPTIONS(parser_format 'asJsonPretty'),
    spec__template json OPTIONS(parser_format 'asJsonPretty'),
    spec__updateStrategy json OPTIONS(parser_format 'asJsonPretty'),

    status__collisionCount integer,
    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__currentNumberScheduled integer,
    status__desiredNumberScheduled integer,
    status__numberAvailable integer,
    status__numberMisscheduled integer,
    status__numberReady integer,
    status__numberUnavailable integer,
    status__observedGeneration long,
    status__updatedNumberScheduled integer,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};daemonset');

CREATE FOREIGN TABLE REPLICASET
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__minReadySeconds integer,
    spec__replicas integer,
    spec__selector json OPTIONS(parser_format 'asJsonPretty'),
    spec__template json OPTIONS(parser_format 'asJsonPretty'),

    status__availableReplicas integer,
    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__fullyLabeledReplicas integer,
    status__observedGeneration long,
    status__replicas integer,
    status__readyReplicas integer,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};replicaset');

CREATE FOREIGN TABLE SECRET
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    stringData json OPTIONS(parser_format 'asJsonPretty'),
    data json OPTIONS(parser_format 'asJsonPretty'),
    immutable boolean,
    type string,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};secret');

CREATE FOREIGN TABLE CERTIFICATE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__expirationSeconds integer,
    spec__extra json OPTIONS(parser_format 'asJsonPretty'),
    spec__groups json,
    spec__request string,
    spec__signerName string,
    spec__uid string,
    spec__usages json,
    spec__username string,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};certificate');

CREATE FOREIGN TABLE ENDPOINT_SLICE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    addressType string,
    endpoints json OPTIONS(parser_format 'asJsonPretty'),
    ports json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};endpointslice');

CREATE FOREIGN TABLE RESOURCE_CLASS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    driverName string,
    parametersRef json OPTIONS(parser_format 'asJsonPretty'),
    suitableNodes json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};resourceclass');

CREATE FOREIGN TABLE RESOURCE_CLAIM
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__allocationMode string,
    spec__resourceClassName string,
    spec__parametersRef json OPTIONS(parser_format 'asJsonPretty'),

    status__allocation json OPTIONS(parser_format 'asJsonPretty'),
    status__deallocationRequested boolean,
    status__driverName string,
    status__reservedFor json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};resourceclaim');

CREATE FOREIGN TABLE POD_SCHEDULING_CONTEXT
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__potentialNodes json OPTIONS(parser_format 'asJsonPretty'),
    spec__selectedNode string,

    status__resourceClaims json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};podschedulingcontext');

CREATE FOREIGN TABLE EVENT
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),
    metadata__creationTimestamp timestamp,

    action string,
    deprecatedCount integer,
    deprecatedFirstTimestamp timestamp,
    deprecatedLastTimestamp timestamp,
    deprecatedSource json OPTIONS(parser_format 'asJsonPretty'),
    eventTime json,
    note string,
    reason string,
    regarding json OPTIONS(parser_format 'asJsonPretty'),
    related json OPTIONS(parser_format 'asJsonPretty'),
    reportingController string,
    reportingInstance string,
    series json OPTIONS(parser_format 'asJsonPretty'),
    type string,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};event');

CREATE FOREIGN TABLE FLOW_SCHEMA
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__distinguisherMethod json OPTIONS(parser_format 'asJsonPretty'),
    spec__matchingPrecedence integer,
    spec__priorityLevelConfiguration json OPTIONS(parser_format 'asJsonPretty'),
    spec__rules json OPTIONS(parser_format 'asJsonPretty'),

    status__conditions json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};flowschema');

CREATE FOREIGN TABLE PRIORITY_LEVEL_CONFIGURATION
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__exempt json OPTIONS(parser_format 'asJsonPretty'),
    spec__type string,
    spec__limited json OPTIONS(parser_format 'asJsonPretty'),

    status__conditions json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};prioritylevelconfiguration');

CREATE FOREIGN TABLE VALIDATING_WEBHOOK_CONFIGURATION
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    webhooks json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};validatingwebhookconfiguration');

CREATE FOREIGN TABLE MUTATING_WEBHOOK_CONFIGURATION
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    status__conditions json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};mutatingwebhookconfiguration');

CREATE FOREIGN TABLE HORIZONTAL_POD_AUTOSCALER
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__minReplicas integer,
    spec__maxReplicas integer,
    spec__metrics json OPTIONS(parser_format 'asJsonPretty'),
    spec__scaleTargetRef json OPTIONS(parser_format 'asJsonPretty'),

    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__currentMetrics json OPTIONS(parser_format 'asJsonPretty'),
    status__currentReplicas integer,
    status__desiredReplicas integer,
    status__lastScaleTime timestamp,
    status__observedGeneration long,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};horizontalpodautoscaler');

CREATE FOREIGN TABLE STORAGE_CLASS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    allowVolumeExpansion boolean,
    allowedTopologies json OPTIONS(parser_format 'asJsonPretty'),
    mountOptions json OPTIONS(parser_format 'asJsonPretty'),
    parameters json OPTIONS(parser_format 'asJsonPretty'),
    provisioner string,
    reclaimPolicy string,
    volumeBindingMode string,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};storageclass');

CREATE FOREIGN TABLE CSI_DRIVER
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__attachRequired boolean,
    spec__fsGroupPolicy string,
    spec__podInfoOnMount boolean,
    spec__requiresRepublish boolean,
    spec__seLinuxMount boolean,
    spec__storageCapacity boolean,
    spec__tokenRequests json OPTIONS(parser_format 'asJsonPretty'),
    spec__volumeLifecycleModes json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};csidriver');

CREATE FOREIGN TABLE CSI_NODE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__drivers json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};csinode');

CREATE FOREIGN TABLE CSI_STORAGE_CAPACITY
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    capacity json OPTIONS(parser_format 'asJsonPretty'),
    maximumVolumeSize json OPTIONS(parser_format 'asJsonPretty'),
    nodeTopology json OPTIONS(parser_format 'asJsonPretty'),
    storageClassName string,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};csistoragecapacity');

CREATE FOREIGN TABLE VOLUME_ATTACHMENT
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__attacher string,
    spec__nodeName string,
    spec__source json OPTIONS(parser_format 'asJsonPretty'),

    status__attachError json OPTIONS(parser_format 'asJsonPretty'),
    status__attached boolean,
    status__attachmentMetadata json OPTIONS(parser_format 'asJsonPretty'),
    status__detachError json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};volumeattachment');

CREATE FOREIGN TABLE JOB
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__activeDeadlineSeconds long,
    spec__backoffLimit integer,
    spec__backoffLimitPerIndex integer,
    spec__completionMode string,
    spec__completions integer,
    spec__manualSelector boolean,
    spec__maxFailedIndexes integer,
    spec__parallelism integer,
    spec__podFailurePolicy json OPTIONS(parser_format 'asJsonPretty'),
    spec__podReplacementPolicy string,
    spec__selector json OPTIONS(parser_format 'asJsonPretty'),
    spec__suspend boolean,
    spec__template json OPTIONS(parser_format 'asJsonPretty'),
    spec__ttlSecondsAfterFinished integer,

    status__active integer,
    status__completedIndexes string,
    status__completionTime timestamp,
    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__failed integer,
    status__failedIndexes string,
    status__ready integer,
    status__startTime timestamp,
    status__succeeded integer,
    status__terminating integer,
    status__uncountedTerminatedPods json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};job');

CREATE FOREIGN TABLE CRON_JOB
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__concurrencyPolicy string,
    spec__failedJobsHistoryLimit integer,
    spec__jobTemplate json OPTIONS(parser_format 'asJsonPretty'),
    spec__schedule string,
    spec__startingDeadlineSeconds long,
    spec__successfulJobsHistoryLimit integer,
    spec__suspend boolean,
    spec__timeZone string,

    status__active json OPTIONS(parser_format 'asJsonPretty'),
    status__lastScheduleTime timestamp,
    status__lastSuccessfulTime timestamp,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};cronjob');

CREATE FOREIGN TABLE POD_DISRUPT_BUDGET
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__maxUnavailable string,
    spec__minAvailable string,
    spec__unhealthyPodEvictionPolicy string,
    spec__selector json OPTIONS(parser_format 'asJsonPretty'),

    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__currentHealthy integer,
    status__desiredHealthy integer,
    status__disruptedPods json OPTIONS(parser_format 'asJsonPretty'),
    status__disruptionsAllowed integer,
    status__expectedPods integer,
    status__observedGeneration long,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};poddisruptbudget');

CREATE FOREIGN TABLE RBAC_ROLE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    rules json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};rbac;role');

CREATE FOREIGN TABLE RBAC_ROLE_BINDING
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    roleRef json OPTIONS(parser_format 'asJsonPretty'),
    subjects json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};rbac;rolebinding');

CREATE FOREIGN TABLE RBAC_CLUSTER_ROLE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    rules json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};rbac;clusterrole');

CREATE FOREIGN TABLE RBAC_CLUSTER_ROLE_BINDING
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    roleRef json OPTIONS(parser_format 'asJsonPretty'),
    subjects json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};rbac;clusterrolebinding');

CREATE FOREIGN TABLE PRIORITY_CLASS
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    description string,
    globalDefault boolean,
    preemptionPolicy string,
    "value" integer,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};priorityclass');

CREATE FOREIGN TABLE API_SERVICE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__caBundle string,
    spec__group string,
    spec__groupPriorityMinimum integer,
    spec__insecureSkipTLSVerify boolean,
    spec__service json OPTIONS(parser_format 'asJsonPretty'),
    spec__version string,
    spec__versionPriority integer,

    status__conditions json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};apiservice');

CREATE FOREIGN TABLE CONFIGMAP
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    binaryData json OPTIONS(parser_format 'asJsonPretty'),
    data json OPTIONS(parser_format 'asJsonPretty'),
    immutable boolean,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};configmap');

CREATE FOREIGN TABLE LIMIT_RANGE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__limits json OPTIONS(parser_format 'asJsonPretty'),

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};limitrange');

CREATE FOREIGN TABLE LEASE
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__namespace string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__acquireTime timestamp,
    spec__holderIdentity string,
    spec__leaseDurationSeconds integer,
    spec__leaseTransitions integer,
    spec__renewTime timestamp,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__namespace+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__namespace, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};lease');

CREATE FOREIGN TABLE CUSTOM_RESOURCE_DEFINITION
(
    clusterName string OPTIONS(val_constant '{{ schema.properties.cluster_name }}'),
    schema string OPTIONS(val_constant '{{ schema.name }}'),
    metadata__name string,
    metadata__labels json OPTIONS(parser_format 'asJsonPretty'),

    spec__conversion json OPTIONS(parser_format 'asJsonPretty'),
    spec__group string,
    spec__names json OPTIONS(parser_format 'asJsonPretty'),
    spec__preserveUnknownFields boolean,
    spec__scope string,
    spec__versions json OPTIONS(parser_format 'asJsonPretty'),

    status__acceptedNames json OPTIONS(parser_format 'asJsonPretty'),
    status__conditions json OPTIONS(parser_format 'asJsonPretty'),
    status__storedVersions json,

    identifier string NOT NULL OPTIONS(val_pk 'clusterName+metadata__name' ),
    PRIMARY KEY(identifier),

    UNIQUE(clusterName, metadata__name)
)
OPTIONS(updatable true,
        supports_idempotency false,
        tags 'kubernetes;{{ schema.properties.cluster_name }};crd;customresourcedefinition');