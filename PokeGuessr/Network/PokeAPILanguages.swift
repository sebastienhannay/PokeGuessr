//
//  PokeAPILanguages.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 20/04/2026.
//

import Foundation

struct PokeAPILanguages {
    
    static func supportedCodes(for locale: Locale = .autoupdatingCurrent) -> Set<String> {
        let lang   = locale.language.languageCode?.identifier ?? ""
        let script = locale.language.script?.identifier
        let region = locale.language.region?.identifier
        
        switch lang {
            case "ja":
                return ["ja", "ja-hrkt", "ja-roma"]
                
            case "zh":
                switch script {
                    case "Hant": return ["zh-hant"]
                    case "Hans": return ["zh-hans"]
                    default:
                        switch region {
                            case "TW", "HK", "MO": return ["zh-hant"]
                            default:               return ["zh-hans"]
                        }
                }
                
            case "pt":
                return ["pt-br"]
                
            case "fr": return ["fr"]
            case "de": return ["de"]
            case "es": return ["es"]
            case "it": return ["it"]
            case "ko": return ["ko"]
            case "cs": return ["cs"]
                
            default:   return ["en"]
        }
    }
}
