// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/grpc;

public type Rectangle record {|
    Point lo = {};
    Point hi = {};
|};

public type Feature record {|
    string name = "";
    Point location = {};
|};

public type Point record {|
    int latitude = 0;
    int longitude = 0;
|};

@grpc:ServiceDescriptor {descriptor: ROOT_DESCRIPTOR, descMap: getDescriptorMap()}
service "RouteGuide" on new grpc:Listener(9000) {

    remote function ListFeatures(Rectangle rectangle) returns stream<Feature, grpc:Error?>|error {
        
        int left = int:min(rectangle.lo.longitude, rectangle.hi.longitude);
        int right = int:max(rectangle.lo.longitude, rectangle.hi.longitude);
        int top = int:max(rectangle.lo.latitude, rectangle.hi.latitude);
        int bottom = int:min(rectangle.lo.latitude, rectangle.hi.latitude);

        Feature[] selectedFeatures = from var feature in FEATURES
            where feature.name != ""
            where feature.location.longitude >= left
            where feature.location.longitude <= right
            where feature.location.latitude >= bottom
            where feature.location.latitude <= top
            select feature;

        return selectedFeatures.toStream();
    }
}
