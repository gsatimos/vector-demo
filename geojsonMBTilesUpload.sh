
#!/bin/bash
#requires MAPBOX_ACCESS_TOKEN environment variable to be set 

GEOJSON_FILE=$1
AWS_PROFILE=$2
MAPBOX_USERNAME=$3
TILESET_NAME=$4
TILESET_DESCRIPTION=$5
ZOOM_MIN=$6
ZOOM_MAX=$7

MBTILES="/tmp/out.mbtiles"
RESPONSE_JSON="/tmp/response.json"

echo "writing .mbtiles from $GEOJSON_FILE"
tippecanoe -o $MBTILES -Z $ZOOM_MIN -z $ZOOM_MAX $GEOJSON_FILE

echo "generating s3 access credentials"
curl -X POST https://api.mapbox.com/uploads/v1/$MAPBOX_USERNAME/credentials?access_token=$MAPBOX_ACCESS_TOKEN > $RESPONSE_JSON
cat $RESPONSE_JSON | jq

echo "processing s3 access credentials"
BUCKET=$(cat $RESPONSE_JSON | jq -r '.bucket')
KEY=$(cat $RESPONSE_JSON | jq -r '.key')
export AWS_ACCESS_KEY_ID=$(cat $RESPONSE_JSON | jq -r '.accessKeyId')
export AWS_SECRET_ACCESS_KEY=$(cat $RESPONSE_JSON | jq -r '.secretAccessKey')
export AWS_SESSION_TOKEN=$(cat $RESPONSE_JSON | jq -r '.sessionToken')
URL=$(cat $RESPONSE_JSON | jq -r '.url')
rm -rf $RESPONSE_JSON


echo "copying $GEOJSON_FILE to bucket: $BUCKET key: $KEY"
aws s3 cp $MBTILES s3://$BUCKET/$KEY 
rm -rf $MBTILES

DATA="{\"tileset\": \"$MAPBOX_USERNAME.$TILESET_NAME\", \"url\": \"$URL\", \"name\": \"$TILESET_DESCRIPTION\"}"

echo "uploading file"
curl -X POST -H "Content-Type: application/json" -d "$DATA" https://api.mapbox.com/uploads/v1/$MAPBOX_USERNAME?access_token=$MAPBOX_ACCESS_TOKEN | jq

