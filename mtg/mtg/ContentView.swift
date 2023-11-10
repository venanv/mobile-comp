import SwiftUI

struct MTGCardView: View {
    var card: MTGCard

    var body: some View {
        VStack {
            if let imageURL = URL(string: card.image_uris?.large ?? "") {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        ProgressView()
                    
                    }
                
                }
            } else {
                Text("Image not available")
            }

            Text(card.name)
                .font(.title)
                .padding()

            VStack(alignment: .leading) {
                Text("Type: \(card.type_line)")
                Text("Oracle Text: \(card.oracle_text)")
                
                Text("Legalities :")
            }
            .padding()
            
        }
    }
}

struct ContentView: View {
    @State private var mtgCards: [MTGCard] = []
    @State private var sortingOption: SortingOption = .name

    let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("Sort by", selection: $sortingOption) {
                        ForEach(SortingOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(sortedMTGCards, id: \.id) { card in
                            NavigationLink(destination: MTGCardView(card: card)) {
                                VStack {
                                    if let imageURL = URL(string: card.image_uris?.small ?? "") {
                                        AsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                            case .failure:
                                                Image(systemName: "exclamationmark.triangle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundColor(.red)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                            case .empty:
                                                ProgressView()
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                            @unknown default:
                                                ProgressView()
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    }
                                    Text(card.name)
                                        .font(.headline)
                                }
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.gray, radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                if let data = loadJSON() {
                    do {
                        let decoder = JSONDecoder()
                        let cards = try decoder.decode(MTGCardList.self, from: data)
                        mtgCards = cards.data
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }
            .navigationBarTitle("MTG Cards")
        }
    }

    var sortedMTGCards: [MTGCard] {
        switch sortingOption {
        case .name:
            return mtgCards.sorted { $0.name < $1.name }
        case .type:
            return mtgCards.sorted { $0.type_line < $1.type_line }
        }
    }

    func loadJSON() -> Data? {
        if let path = Bundle.main.path(forResource: "WOT-Scryfall", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
        return nil
    }
}

enum SortingOption: String, CaseIterable {
    case name = "Name"
    case type = "Type"
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
