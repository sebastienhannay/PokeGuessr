//
//  PokeAPIClient.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 14/04/2026.
//

import Foundation
import SwiftData



final class PokeAPIClient {
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2")!
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // Generic fetch
    private func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PokeAPIError.missingData("Invalid response type")
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                throw PokeAPIError.requestFailed(statusCode: httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder.pokeAPIDecoder.decode(T.self, from: data)
            } catch {
                throw PokeAPIError.decodingFailed(error)
            }
            
        } catch {
            throw PokeAPIError.networkError(error)
        }
    }
}

extension PokeAPIClient {
    
    func getPokemon(id: Int, in context: ModelContext) async throws -> Pokemon {
        
        if let existing = try Pokemon.fetchExisting(id: id, in: context) {
            return existing
        }
        
        let pokemonURL = baseURL.appendingPathComponent("pokemon/\(id)")
        
        // fetch Pokemon
        let pokemonDTO: PokemonDTO = try await fetch(PokemonDTO.self, from: pokemonURL)
        
        // fetch related species
        guard let speciesURL = URL(string: pokemonDTO.species.url) else {
            throw PokeAPIError.missingData(pokemonDTO.species.url)
        }
        let speciesDTO: PokemonSpeciesDTO = try await fetch(PokemonSpeciesDTO.self, from: speciesURL)
        
        // fetch related form
        guard let formPath = pokemonDTO.forms.first?.url, let formURL = URL(string: formPath) else {
            throw PokeAPIError.missingData(pokemonDTO.forms.first?.url ?? "No form")
        }
        let formDTO: PokemonFormDTO = try await fetch(PokemonFormDTO.self, from: formURL)
        
        let entity = mapToPokemonEntity(pokemon: pokemonDTO, species: speciesDTO, form: formDTO)
        
        context.insert(entity)
        try context.save()
        
        return entity
    }
}

private extension PokeAPIClient {
    
    func mapToPokemonEntity(
        pokemon: PokemonDTO,
        species: PokemonSpeciesDTO,
        form: PokemonFormDTO
    ) -> Pokemon {
        
        let entity = Pokemon(
            id: pokemon.id,
            name: pokemon.name,
            height: pokemon.height,
            weight: pokemon.weight,
            baseExperience: pokemon.baseExperience,
            isLegendary: species.isLegendary,
            isMythical: species.isMythical,
            isBaby: species.isBaby,
            captureRate: species.captureRate,
            baseHappiness: species.baseHappiness,
            evolutionChainURL: species.evolutionChain.url
        )
        
        // MARK: - Stats
        entity.stats = pokemon.stats.map {
            PokemonStatEntity(
                name: $0.stat.name,
                value: $0.baseStat
            )
        }
        
        // MARK: - Types
        entity.types = pokemon.types.map {
            PokemonTypeEntity(
                name: $0.type.name,
                slot: $0.slot
            )
        }
        
        // MARK: - Abilities
        entity.abilities = pokemon.abilities.map {
            PokemonAbilityEntity(
                name: $0.ability.name,
                isHidden: $0.isHidden
            )
        }
        
        // MARK: - Names (all languages)
        entity.names = species.names.map {
            PokemonNameEntity(
                name: $0.name,
                languageCode: $0.language.name
            )
        }
        
        entity.formSpecificNames = form.names.map {
            PokemonNameEntity(
                name: $0.name,
                languageCode: $0.language.name
            )
        }
        
        // MARK: - Genera
        entity.genera = species.genera.map {
            PokemonGenusEntity(
                genus: $0.genus,
                languageCode: $0.language.name
            )
        }
        
        // MARK: - Flavor texts
        entity.flavorTexts = species.flavorTextEntries.map {
            PokemonFlavorTextEntity(
                text: $0.flavorText,
                languageCode: $0.language.name,
                versionName: $0.version.name
            )
        }
        
        // MARK: - Cries
        let cries = pokemon.cries
        entity.cries = PokemonCriesEntity(
            latest: cries.latest,
            legacy: cries.legacy
        )
        
        // MARK: - Sprites (flattened)
        let sprites = pokemon.sprites
        entity.sprites = PokemonSpritesEntity(
            frontDefault: sprites.frontDefault,
            frontShiny: sprites.frontShiny,
            backDefault: sprites.backDefault,
            backShiny: sprites.backShiny,
            officialArtwork: sprites.other?.officialArtwork?.frontDefault,
            officialArtworkShiny: sprites.other?.officialArtwork?.frontShiny,
            homeDefault: sprites.other?.home?.frontDefault,
            homeShiny: sprites.other?.home?.frontShiny,
            dreamWorld: sprites.other?.dreamWorld?.frontDefault
        )
        
        return entity
    }
}

private extension JSONDecoder {
    static let pokeAPIDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
