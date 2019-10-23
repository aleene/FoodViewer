//
//  ProhibitedBrands.swift
//  FoodViewer
//
//  Created by arnaud on 23/10/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation


class ProhibitedBrands {

    private let List = [
        // Scamark
    "marque-repere","bio-village", "delisse", "rustica", "cote-table", "p-tit-deli",
    "les-croises", "turini", "peche-ocean", "jafaden", "tokapi", "tradilege",
    "ferial", "epi-d-or", "scamark-filiale-e-leclerc", "douceur-du-verger",
    "cote-snack", "ronde-des-mers", "pic-express", "saint-azay",
    "pom-lisse", "tables-du-monde", "plantation", "nat-vie", "tablier-blanc", "volandry",
    "smicy", "eskiss", "saint-charmin", "chaque-jour-sans-gluten", "tablette-d-or",
    "brin-de-jour", "comptoir-du-grain", "regal-soupe", "menu-fraicheur", "copains-copines",
    "vieux-carion","frucci", "couleurs-vives", "chantet-blanet", "les-caracteres",
    "terrasses-d-autan", "trofic", "equador", "rives-et-terrasses", "leclerc", "trium",
    "mamie-douceur", "pause-fraicheur", "antoine-barrier", "sprink-s", "fruistar",
    "prieur-barsanne", "festalie", "oeufs-de-nos-regions", "fresh-tea", "auguste-mugniot",
    "confiseo", "terres-ocrees", "lagoa", "adrien-champaud", "britley-s",
    "autour-du-dessert", "tisea", "nid-d-abeille", "jean-s", "falsbourg", "les-goelleries",
    "x-tense", "rebmann", "britley", "teva", "pol-carson", "chantegril", "gregoire-xi",
    "edulcorel", "pierre-de-chaumeyrac","new-r","laqueuille","bon-choco",
    "lagoa-cocktail", "e-leclerc", "novotna", "day-break", "desquiles", "baird-s",
    "o-fresh", "chaque-jour-reduit-en-lactose", "volpone", "nustikao", "pulp-orange","dorrao",
    "voltano","frucci-soda", "guillaume-d-arria", "vivalis", "hilborg", "abbaye-alveringem",
    "deli-del-o", "scamark", "rives-terrasses", "nadya", "entr-aide", "duc-de-borzac",
    "maitre-coquille","cote-croc","deli-delo", "loella", "diane-d-arria","sidi-youssouf",
    "brighton-s", "deli-light", "saint-diery", "bordeaux", "kermene",
        "jafaden-%E2%99%A6-marque-repere","gibus", "repere", "john-davon-s","maitre-prunille",
        "extra-strong", "la-cave-du-marmandais", "recoltons-l-avenir", "5-lager",
        "notre-jardin-%E2%99%A6-marque-repere", "petit-navire", "maques-del-dominio", "charal",
        "blazer", "marque-repere",
    // Systeme-U
        "u",
        "u-bio",
        "u-saveurs",
        "u-tout-petits",
        "u-mat-lou",
        "u-sans-gluten",
        "u-oxygn",
        "u-bon-vegetarien",
        "nor-u",
        "super-u",
    // Barilla
        "barilla",
        "harrys",
        "academia",
        "la-collezione-d-italia",
        "academia-barilla",
        "barilla-piccolini",
        "barilla-france-sas",
        "harris",
        "barilla-collezione"
    ]
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    static let manager = ProhibitedBrands()

    init() { }
    
    func contains(brands: [String]) -> Bool {
        if let firstBrand = brands.first {
            //let test = List.contains(firstBrand)
            return List.contains(firstBrand)
        }
        return false
    }
}
