0. Edit Options
1. Build docker images and push to ECR
2. Create Task Definitions (ecs-task-definition.conf)
3. Update Service 

# Edit Below Options
DATE=$(date '+%Y-%m-%d-%H-%M-%S')
echo $DATE
ECR_URL="12345678987.dkr.ecr.ap-northeast-2.amazonaws.com"
DOCKER_IMAGE_NAME="jelly/ecs-session-example"

DIR="$( cd "$( dirname "$0" )" && pwd )"
TASK_DEF_NAME="ecs-session-example"
TASK_DEF_CONF="ecs-task-definition.conf"

CLUSTER_NAME="Jellys-Toy-Cluster"
SERVICE_CONF="ecs-service.conf"

MINIMUM_HEALTHY_PERCENT=100
MAXIMUM_PERCENT=200
SUBNETS='"subnet-xxxxxxxxxxxxxx","subnet-xxxxxxxxxxxxxxxx"'
SECURITY_GROUPS='"sg-XXXXXXXXXXXXXXX"'

DESIRED_COUNT=2


$(aws ecr get-login --no-include-email --region ap-northeast-2) && \
docker build -t ${DOCKER_IMAGE_NAME}:${DATE} . && \
docker tag ${DOCKER_IMAGE_NAME}:${DATE} ${ECR_URL}/${DOCKER_IMAGE_NAME}:${DATE} && \
docker push ${ECR_URL}/${DOCKER_IMAGE_NAME}:${DATE} && \
cp ${TASK_DEF_CONF} ${TASK_DEF_CONF}-${DATE} && \
sed -i '' "s#DOCKER_IMAGE_NAME#${ECR_URL}/${DOCKER_IMAGE_NAME}:${DATE}#g" ${TASK_DEF_CONF}-${DATE} && \
sed -i '' "s#TASK_DEF_NAME#${TASK_DEF_NAME}#g" ${TASK_DEF_CONF}-${DATE} && \
aws ecs register-task-definition --family ${TASK_DEF_NAME} --cli-input-json file://${DIR}/${TASK_DEF_CONF}-${DATE} && \
rm ${TASK_DEF_CONF}-${DATE} && \
sleep 10 && \
cp ${SERVICE_CONF} ${SERVICE_CONF}-${DATE} && \
sed -i '' "s#CLUSTER_NAME#${CLUSTER_NAME}#g" ${SERVICE_CONF}-${DATE} && \
sed -i '' "s#DESIRED_COUNT#${DESIRED_COUNT}#g" ${SERVICE_CONF}-${DATE} && \
sed -i '' "s#TASK_DEF_NAME#${TASK_DEF_NAME}#g" ${SERVICE_CONF}-${DATE} && \
sed -i '' "s#SUBNETS#${SUBNETS}#g" ${SERVICE_CONF}-${DATE} && \
sed -i '' "s#SECURITY_GROUPS#${SECURITY_GROUPS}#g" ${SERVICE_CONF}-${DATE} && \
sed -i '' "s#MAXIMUM_PERCENT#${MAXIMUM_PERCENT}#g" ${SERVICE_CONF}-${DATE} && \
sed -i '' "s#MINIMUM_HEALTHY_PERCENT#${MINIMUM_HEALTHY_PERCENT}#g" ${SERVICE_CONF}-${DATE} && \


aws ecs update-service --cli-input-json file://${DIR}/${SERVICE_CONF}-${DATE}

rm ${SERVICE_CONF}-${DATE}


