//
//  OFFProduct.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class OFFProduct: Codable {
    
    // the vars are those that the user can create/edit
    var additives: String? = nil
    var additives_debug_tags: [String]? = nil
    var additives_old_tags: [String]? = nil
    var additives_prev: String? = nil
    var additives_prev_n: Int? = nil
    var additives_prev_tags: [String]? = nil
        var additives_tags: [String]? = nil
    var allergens: String? = nil
    var allergens_hierarchy: [String]? = nil
    var allergens_tags: [String]? = nil
    var amino_acids_tags: [String]? = nil
    var brands: String? = nil
        var brands_tags: [String]? = nil
    var categories: String? = nil
    var categories_debug_tags: [String]? = nil
    var categories_hierarchy: [String]? = nil
    var categories_prev_hierarchy: [String]? = nil
    var categories_prev_tags: [String]? = nil
        var categories_tags: [String]? = nil
    var checkers_tags: [String]? = nil
        var cities_tags: [String]? = nil
    var complete: Int? = nil
    var completed_t: Date? = nil
    var correctors_tags: [String]? = nil
    var countries: String? = nil
    var countries_hierarchy: [String]? = nil
        var countries_tags: [String]? = nil
    var created_t: Date? = nil // 1410949750
    var creator: String? = nil
    var editors: [String]? = nil
    var editors_tags: [String]? = nil
    var emb_codes: String? = nil
    var emb_codes_20141016: String? = nil
    var emb_codes_orig: String? = nil
        var emb_codes_tags: [String]? = nil
        var expiration_date: String? = nil // "04/12/2016"
    var entry_dates_tags: [String]? = nil
    // generic_name_fr is handled in the child
    var generic_name: String? = nil
    var id: String? = nil
    var image_front_small_url: URL? = nil
    var image_front_thumb_url: URL? = nil
    var image_front_url: URL? = nil
    var image_ingredients_small_url: URL? = nil
    var image_ingredients_thumb_url: URL? = nil
    var image_ingredients_url: URL? = nil
    var image_nutrition_small_url: URL? = nil
    var image_nutrition_thumb_url: URL? = nil
    var image_nutrition_url: URL? = nil
    var image_small_url: URL? = nil
    var image_thumb_url: URL? = nil
    var image_url: String? = nil
    var images: [String:OFFProductImageDetailed]? = nil
    var informers_tags: [String]? = nil
    // var ingredients: [OFFProductIngredient]? = nil
    var ingredients_analysis_tags: [String?]? = nil // evaluation of ingredients
    // var ingredients_debug: [String?]? = nil
    var ingredients_from_palm_oil_tags: [String]? = nil
    // var ingredients_ids_debug: [String]? = nil
    // var ingredients_n_tags: [String]? = nil
    // var ingredients_tags: [String]? = nil // detected ingredients + parents
    var ingredients_hierarchy: [String]? = nil
    var ingredients_original_tags: [String]? = nil // detected ingredients
    var ingredients_text: String? = nil
    // ingredients_text_fr is handled in the child
    // var ingredients_text_debug: String? = nil
    var ingredients_that_may_be_from_palm_oil_tags: [String]? = nil
    var ingredients_text_with_allergens: String? = nil
    // var ingredients_text_with_allergens_fr is handled in the child
    var interface_version_created: String? = nil  // not always with value
    var interface_version_modified: String? = nil
    var labels: String? = nil
    var labels_debug_tags: [String]? = nil
    var labels_hierarchy: [String]? = nil
    var labels_prev_hierarchy: [String]? = nil
    var labels_prev_tags: [String]? = nil
        var labels_tags: [String]? = nil
    var lang: String? = nil
    var languages: [String:Int]? = nil
    var languages_hierarchy: [String]? = nil
    var languages_tags: [String]? = nil
    var last_edit_dates_tags: [String]? = nil
    var last_editor: String? = nil
    var last_image_dates_tags: [String]? = nil
    var last_image_t: Date? = nil
    var last_modified_by: String? = nil
    var last_modified_t: Date? = nil // 1463315494
    var lc: String? = nil
        var link: String? = nil
    var manufacturing_places: String? = nil
        var manufacturing_places_tags: [String]? = nil
    var minerals_tags: [String]? = nil
    var new_additives_n: Int? = nil
    var no_nutrition_data: String? = nil
    var nova_group_debug: String? = nil
    var nova_groups_tags: [String]? = nil
    // var nova-group: String? = nil the - is not allowed
    var nutrient_levels: OFFProductNutrientLevels? = nil
    var nutrient_levels_tags: [OFFProductNutrientLevel]? = nil
    var nutrition_grade_fr: String? = nil
    var nutrition_score_debug: String? = nil
        var nutriments: OFFProductNutriments? = nil
    var nutrition_data_per: String? = nil
    var nutrition_grades_tags: [String]? = nil
    var nutriscore_data: OFFProductNutriScoreData? = nil
    var origins: String? = nil
        var origins_tags: [String]? = nil
    var other_nutritional_substances_tags: [String]? = nil
    var packaging: String? = nil
        var packaging_tags: [String]? = nil
    var period_after_opening: String? = nil
    var photographers_tags: [String]? = nil
    var pnns_groups_1: String? = nil
    var pnns_groups_1_tags: [String]? = nil
    var pnns_groups_2: String? = nil
    var pnns_groups_2_tags: [String]? = nil
    var product_name: String? = nil
    // product_name_fr is handled in the child
    var purchase_places: String? = nil
        var purchase_places_tags: [String]? = nil
        var quantity: String? = nil
    var scans_n: Int? = nil
    var selected_images: OFFProductSelectedImages? = nil
    var server: String? = nil
        var serving_size: String? = nil
    var states: String? = nil
    var states_hierarchy: [OFFProductStates]? = nil
        var states_tags: [OFFProductStates]? = nil
    var stores: String? = nil
        var stores_tags: [String]? = nil
    var traces: String? = nil
    var traces_from_user: String? = nil
    var traces_hierarchy: [String]? = nil
    var traces_from_ingredients: String? = nil
        var traces_tags: [String]? = nil
    var unique_scans_n: Int? = nil
    var unknown_nutrients_tags: [String]? = nil
    var update_key: String? = nil
    var vitamins_tags: [String]? = nil
    var nucleotides_tags: [String]? = nil
    var _id: String? = nil
    var _keywords: [String]? = nil
    
}
