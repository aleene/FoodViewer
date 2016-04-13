# FoodViewer

## Purpose
The purpose of this app is to view products stored in the Open Food Facts database. The user enters a barcode, either by scanning or manual entry, and the app retrieves the corresponding information if available.

## User group
The app is intended for users that help maintain the OFF products database. It helps finding elements of a product that are lacking or wrongly entered. However it can also be used by anyone interested in reading the labels on products.

#Capabilities
The main purpose of the app is viewing the OFFproduct data for specic products.

##History
The app maintains a history of searches carried out by the user. The maximum size of this list is 100 products.

##Taxonomy support
The app uses the various taxonomies defined by OFF (status, allergens, additives, global labels, categories). These are used for translation purpose. It helps also to pinpoint tags, which are either not yet translated or are not a part of a taxonomy yet.


## Requirements
This application is written in Swift 2.2 using Xcode 7.3. Target is IOS 9.2
