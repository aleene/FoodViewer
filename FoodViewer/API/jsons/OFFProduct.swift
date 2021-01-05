//
//  OFFProduct.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

/// This class decodes the OFF json that contains a single product.
/// Only the straight decodable parameters are contained in this class
/// The child class OFFDetailedProduct contains the variables that need more attention
class OFFProduct: Codable {
    
    // the vars are those that the user can create/edit
    var additives: String? = nil
    var additives_debug_tags: [String]? = nil
    //var additives_n: Int? = nil is in OFFProductDetailed
    //var additives_old_n: Int? = nil is in OFFProductDetailed
    var additives_old_tags: [String]? = nil
    var additives_original_tags: [String]? = nil
    var additives_prev: String? = nil
    var additives_prev_n: Int? = nil
    var additives_prev_tags: [String]? = nil
        var additives_tags: [String]? = nil
    var allergens: String? = nil
    var allergens_from_ingredients: String? = nil
    var allergens_from_user: String? = nil
    var allergens_hierarchy: [String]? = nil
    var allergens_tags: [String]? = nil
    var amino_acids_prev_tags: [String]? = nil
    var amino_acids_tags: [String]? = nil
    var attribute_groups: [OFFProductAttributeGroup]? = nil
    var brands: String? = nil
        var brands_tags: [String]? = nil
    // var carbon_footprint_percent_of_known_ingredients: Double? = nil is in OFFProductDetailed
    // var carbon_footprint_from_known_ingredients_debug: Int? = nil is in OFFProductDetailed
    var categories: String? = nil
    var categories_debug_tags: [String]? = nil
    var categories_hierarchy: [String]? = nil
    var categories_lc: String? = nil
    var categories_prev_hierarchy: [String]? = nil
    var categories_prev_tags: [String]? = nil
    //var categories_properties: CiqualFoodName? = nil
    //var category_properties: CiqualFoodName? = nil
    var categories_properties_tags: [String]? = nil
        var categories_tags: [String]? = nil
    var checkers_tags: [String]? = nil
    var ciqual_food_name_tags: [String]? = nil
        var cities_tags: [String]? = nil
    // var code: String? = nil is in OFFProductDetailed
    // var codes_tags: [String]? = nil is in OFFProductDetailed
    var compared_to_category: String? = nil
    var complete: Int? = nil
    var completed_t: Date? = nil
    // var completeness: Double? = nil is in OFFProductDetailed
    var conservation_conditions: String? = nil
    var correctors_tags: [String]? = nil
    var countries: String? = nil
    var countries_debug_tags: [String]? = nil
    var countries_hierarchy: [String]? = nil
    var countries_lc: String? = nil
        var countries_tags: [String]? = nil
    var created_t: Date? = nil // 1410949750
    var creator: String? = nil
    var customer_service: String? = nil
    var data_quality_bugs_tags: [String]? = nil
    var data_quality_errors_tags: [String]? = nil
    var data_quality_info_tags: [String]? = nil
    var data_quality_warnings_tags: [String]? = nil
    var data_quality_tags: [String]? = nil
    var data_sources: String? = nil
    var data_sources_tags: [String]? = nil
    var debug_param_sorted_langs: [String]? = nil
    //var ecoscore_alpha: String? = nil
    var ecoscore_data: OFFProductEcoscoreData? = nil
    var ecoscore_grade: String? = nil
    var editors: [String]? = nil
    var editors_tags: [String]? = nil
    var emb_codes: String? = nil
    var emb_codes_20141016: String? = nil
    var emb_codes_orig: String? = nil
        var emb_codes_tags: [String]? = nil
        var expiration_date: String? = nil // "04/12/2016"
    var entry_dates_tags: [String]? = nil
    var forest_footprint_data: OFFProductForestFootPrintData? = nil
    // generic_name_fr is handled in the child
    //var fruits-vegetables-nuts_100g_estimate: Int? = nil
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
    var image_packaging_small_url: URL? = nil
    var image_packaging_thumb_url: URL? = nil
    var image_packaging_url: URL? = nil
    var image_small_url: URL? = nil
    var image_thumb_url: URL? = nil
    var image_url: String? = nil
    var images: [String:OFFProductImageDetailed]? = nil
    var informers_tags: [String]? = nil
    // var ingredients: [OFFProductIngredient]? = nil
    var ingredients_analysis_tags: [String?]? = nil // evaluation of ingredients
    // var ingredients_debug: [String?]? = nil
    // var ingredients_from_palm_oil_n: Int? = nil is in OFFProductDetailed
    var ingredients_from_palm_oil_tags: [String]? = nil
    var ingredients_hierarchy: [String]? = nil
    // var ingredients_ids_debug: [String]? = nil
    // var ingredients_n: Int? = nil is in OFFProductDetailed
    // var ingredients_n_tags: [String]? = nil
    var ingredients_original_tags: [String]? = nil // detected ingredients
    var ingredients_percent_analysis: Int? = nil
    var ingredients_tags: [String]? = nil
    var ingredients_text: String? = nil
    // ingredients_text_fr is handled in the child
    // var ingredients_text_debug: String? = nil
    var ingredients_text_with_allergens: String? = nil
    // var ingredients_text_with_allergens_fr is in OFFProductDetailed
    // var ingredients_that_may_be_from_palm_oil_n: Int? = nil is in OFFProductDetailed
    var ingredients_that_may_be_from_palm_oil_tags: [String]? = nil
    var interface_version_created: String? = nil  // not always with value
    var interface_version_modified: String? = nil
    var known_ingredients_n: Int? = nil
    var labels: String? = nil
    var labels_debug_tags: [String]? = nil
    var labels_hierarchy: [String]? = nil
    var labels_lc: String? = nil
    var labels_prev_hierarchy: [String]? = nil
    var labels_prev_tags: [String]? = nil
        var labels_tags: [String]? = nil
    var lang: String? = nil
    var languages: [String:Int]? = nil
    // var languages_codes: LanguageCodes? = nil
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
    // var max_imgid: String? = nil is in OFFProductDetailed
    var minerals_prev_tags: [String]? = nil
    var minerals_tags: [String]? = nil
    var misc_tags: [String]? = nil
    var new_additives_n: Int? = nil
    var no_nutrition_data: String? = nil
    // var nova_group: Int? = nil is in OFFProductDetailed
    var nova_group_debug: String? = nil
    var nova_groups_tags: [String]? = nil
    var nucleotides_prev_tags: [String]? = nil
    var nucleotides_tags: [String]? = nil
    var nutrient_levels: OFFProductNutrientLevels? = nil
    var nutrient_levels_tags: [OFFProductNutrientLevel]? = nil
    var nutriscore_data: OFFProductNutriScoreData? = nil
    var nutriscore_grade: String? = nil
    var nutriscore_score: Int? = nil
    var nutrition_data: String? = nil
    var nutrition_data_per: String? = nil
    var nutrition_data_prepared: String? = nil
    var nutrition_data_prepared_per: String? = nil
    var nutrition_grade_fr: String? = nil
    var nutrition_grades_tags: [String]? = nil
    var nutrition_score_beverage: Int? = nil
    var nutrition_score_debug: String? = nil
    var nutrition_score_warning_fruits_vegetables_nuts_estimate_from_ingredients: Int? = nil
    // var nutrition_score_warning_fruits_vegetables_nuts_estimate_from_ingredients_value: Double? = nil is handled in the child
    var nutrition_score_warning_no_fiber: Int? = nil
        var nutriments: OFFProductNutriments? = nil
    var origins: String? = nil
        var origins_tags: [String]? = nil
    // var other_information_nl: String? = nil is handled in OFFProductDetailed
    var other_nutritional_substances_tags: [String]? = nil
    var packaging: String? = nil
        var packaging_tags: [String]? = nil
    var period_after_opening: String? = nil
    var photographers_tags: [String]? = nil
    var pnns_groups_1: String? = nil
    var pnns_groups_1_tags: [String]? = nil
    var pnns_groups_2: String? = nil
    var pnns_groups_2_tags: [String]? = nil
    // var popularity_key: Int? = nil is handled in OFFProductDetailed
    var popularity_tags: [String]? = nil
    // var preparation_fr: String? = nil is handled in OFFProductDetailed
    var producer: String? = nil
    // var producer_nl: String is handled in OFFProductDetailed
    var product_name: String? = nil
    // var product_quantity: String? = nil is handled in OFFProductDetailed
    // product_name_fr is handled in the child
    var purchase_places: String? = nil
        var purchase_places_tags: [String]? = nil
        var quantity: String? = nil
    // var rev: Int? = nil is in OFFProductDetailed
    var scans_n: Int? = nil
    var selected_images: OFFProductSelectedImages? = nil
    var server: String? = nil
        var serving_size: String? = nil
    // var serving_quantity: String? = nil is in OFFProductDetailed
    // var sortkey: Int? = nil is in OFFProductDetailed
    var states: String? = nil
    var states_hierarchy: [OFFProductStates]? = nil
        var states_tags: [OFFProductStates]? = nil
    var stores: String? = nil
        var stores_tags: [String]? = nil
    var teams: String? = nil
    var traces: String? = nil
    var traces_from_ingredients: String? = nil
    var traces_from_user: String? = nil
    var traces_hierarchy: [String]? = nil
        var traces_tags: [String]? = nil
    var unique_scans_n: Int? = nil
    // var unknown_ingredients_n: Int? = nil is in OFFProductDetailed
    var unknown_nutrients_tags: [String]? = nil
    var update_key: String? = nil
    var vitamins_prev_tags: [String]? = nil
    var vitamins_tags: [String]? = nil
    var warning: String? = nil
    var _id: String? = nil
    var _keywords: [String]? = nil
    
}
