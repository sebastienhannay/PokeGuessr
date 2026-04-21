//
//  MockURLProtocol.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 21/04/2026.
//


//
//  PokeAPIClientTests.swift
//  PokeGuessrTests
//

import Testing
import Foundation
import SwiftData
@testable import PokeGuessr

// MARK: - Mock URLSession

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    static func register(_ map: [String: (Int, Data)]) {
        requestHandler = { request in
            guard let url = request.url?.absoluteString,
                  let (status, data) = map.first(where: { url.contains($0.key) })?.value
            else { throw URLError(.badURL) }

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: status,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
    }
}

// MARK: - Test Container

@MainActor
private func makeTestContainer() throws -> ModelContainer {
    let schema = Schema([Pokemon.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: config)
}

private func makeSUT() -> PokeAPIClient {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return PokeAPIClient(session: URLSession(configuration: config))
}

// MARK: - Tests

@Suite("PokeAPIClient", .serialized)
@MainActor
struct PokeAPIClientTests {
    
    let pokemonData: Data
    let speciesData: Data
    let formData: Data
    let container: ModelContainer = .inMemory

    init() async throws {
        let session = URLSession.shared
        let base = URL(string: "https://pokeapi.co/api/v2")!
        
        let pokemonId = 25

        async let pokemon = session.data(from: base.appendingPathComponent("pokemon/\(pokemonId)")).0
        async let species = session.data(from: base.appendingPathComponent("pokemon-species/\(pokemonId)")).0
        async let form    = session.data(from: base.appendingPathComponent("pokemon-form/\(pokemonId)")).0

        (pokemonData, speciesData, formData) = try await (pokemon, species, form)
    }
    
    private var context: ModelContext { container.mainContext }

    // MARK: - Helpers

    private func registerFixtures() {
        MockURLProtocol.register([
            "pokemon/25":         (200, pokemonData),
            "pokemon-species/25": (200, speciesData),
            "pokemon-form/25":    (200, formData)
        ])
    }

    private func makeSUT() -> PokeAPIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return PokeAPIClient(session: URLSession(configuration: config))
    }

    // MARK: - Core fields

    @Test("Maps core Pokémon fields correctly")
    func fetchPokemonCoreFields() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)
        
        #expect(pokemon.id == 25)
        #expect(pokemon.name == "pikachu")
        #expect(pokemon.height == 4)
        #expect(pokemon.weight == 60)
        #expect(pokemon.baseExperience == 112)
    }

    // MARK: - Species fields

    @Test("Maps species flags and rates correctly")
    func fetchSpeciesFields() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.isLegendary == false)
        #expect(pokemon.isMythical == false)
        #expect(pokemon.isBaby == false)
        #expect(pokemon.captureRate == 190)
        #expect(pokemon.baseHappiness == 70)
        #expect(pokemon.evolutionChainURL == "https://pokeapi.co/api/v2/evolution-chain/10/")
    }

    // MARK: - Relationships

    @Test("Maps all 6 base stats")
    func mapsStats() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.stats.count == 6)
        #expect(pokemon.stats.first(where: { $0.name == "hp" })?.value == 35)
        #expect(pokemon.stats.first(where: { $0.name == "attack" })?.value == 55)
        #expect(pokemon.stats.first(where: { $0.name == "defense" })?.value == 40)
        #expect(pokemon.stats.first(where: { $0.name == "special-attack" })?.value == 50)
        #expect(pokemon.stats.first(where: { $0.name == "special-defense" })?.value == 50)
        #expect(pokemon.stats.first(where: { $0.name == "speed" })?.value == 90)
    }

    @Test("Maps types correctly")
    func mapsTypes() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.types.count == 1)
        #expect(pokemon.types.first?.name == "electric")
        #expect(pokemon.types.first?.slot == 1)
    }

    @Test("Maps abilities including hidden flag")
    func mapsAbilities() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.abilities.count == 2)
        #expect(pokemon.abilities.first(where: { $0.name == "static" })?.isHidden == false)
        #expect(pokemon.abilities.first(where: { $0.name == "lightning-rod" })?.isHidden == true)
    }

    // MARK: - Localised content

    @Test("Maps 11 multilingual names from species")
    func mapsNames() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.names.count == 11)
        #expect(pokemon.names.first(where: { $0.languageCode == "en" })?.name == "Pikachu")
        #expect(pokemon.names.first(where: { $0.languageCode == "fr" })?.name == "Pikachu")
        #expect(pokemon.names.first(where: { $0.languageCode == "ja" })?.name == "ピカチュウ")
    }

    @Test("Form-specific names are empty for base Pikachu")
    func formSpecificNamesAreEmpty() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.formSpecificNames.isEmpty)
    }

    @Test("Maps 10 genera and resolves English genus")
    func mapsGenera() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.genera.count == 10)
        #expect(pokemon.genera.first(where: { $0.languageCode == "en" })?.genus == "Mouse Pokémon")
    }

    @Test("Maps 135 flavor text entries")
    func mapsFlavorTexts() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.flavorTexts.count == 135)
        #expect(pokemon.flavorTexts.first(where: { $0.versionName == "red" && $0.languageCode == "en" }) != nil)
    }

    // MARK: - Sprites & artwork

    @Test("Maps all sprite URLs correctly")
    func mapsSprites() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.sprites?.frontDefault == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png")
        #expect(pokemon.sprites?.frontShiny == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/25.png")
        #expect(pokemon.sprites?.backDefault == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/25.png")
        #expect(pokemon.sprites?.backShiny == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/25.png")
        #expect(pokemon.sprites?.officialArtwork == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png")
        #expect(pokemon.sprites?.officialArtworkShiny == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/25.png")
        #expect(pokemon.sprites?.homeDefault == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/25.png")
        #expect(pokemon.sprites?.homeShiny == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/25.png")
        #expect(pokemon.sprites?.dreamWorld == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/25.svg")
    }

    @Test("artwork computed property resolves to official artwork URL")
    func artworkResolvesToOfficialArtwork() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.artwork == URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png"))
    }

    // MARK: - Cries

    @Test("Maps latest and legacy cry URLs")
    func mapsCries() async throws {
        registerFixtures()
        let pokemon = try await makeSUT().getPokemon(id: 25, in: context)

        #expect(pokemon.cries?.latest == "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/25.ogg")
        #expect(pokemon.cries?.legacy == "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/legacy/25.ogg")
    }

    // MARK: - Caching

    @Test("Returns cached Pokémon without a second network call")
    func returnsCachedPokemon() async throws {
        registerFixtures()
        let sut = makeSUT()

        let first = try await sut.getPokemon(id: 25, in: context)

        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }

        let second = try await sut.getPokemon(id: 25, in: context)
        #expect(first.id == second.id)
    }

    @Test("Persists Pokémon so a brand-new ModelContext finds it")
    func persistsToSwiftData() async throws {
        registerFixtures()
        let container = try makeTestContainer()
        _ = try await makeSUT().getPokemon(id: 25, in: container.mainContext)

        let freshContext = ModelContext(container)
        let results = try freshContext.fetch(FetchDescriptor<Pokemon>(
            predicate: #Predicate { $0.id == 25 }
        ))

        #expect(results.count == 1)
        #expect(results.first?.name == "pikachu")
    }

    // MARK: - Error handling

    @Test("Throws for a 404 HTTP response")
    func throwsOnHTTPError() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        await #expect(throws: PokeAPIError.self) {
            _ = try await makeSUT().getPokemon(id: 999, in: context)
        }
    }

    @Test("Throws when the network is unreachable")
    func throwsOnNetworkFailure() async throws {
        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }
        await #expect(throws: PokeAPIError.self) {
            _ = try await makeSUT().getPokemon(id: 1, in: context)
        }
    }

    @Test("Throws for malformed JSON")
    func throwsOnBadJSON() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("💥 not json 💥".utf8))
        }
        await #expect(throws: PokeAPIError.self) {
            _ = try await makeSUT().getPokemon(id: 1, in: context)
        }
    }
}
