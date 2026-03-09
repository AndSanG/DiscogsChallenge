import Foundation

struct PrototypeArtist: Identifiable, Hashable {
    let id: Int
    let name: String
    let profile: String
    let members: [PrototypeMember]
}

struct PrototypeMember: Identifiable, Hashable {
    let id: Int
    let name: String
    let isActive: Bool
}

struct PrototypeRelease: Identifiable {
    let id: Int
    let title: String
    let year: Int?
    let genres: [String]
    let labels: [String]
    let type: String
}

enum PrototypeData {
    static let artists: [PrototypeArtist] = [
        PrototypeArtist(
            id: 1,
            name: "Radiohead",
            profile: "Radiohead are an English rock band formed in Abingdon, Oxfordshire, in 1985. The band consists of Thom Yorke, Jonny Greenwood, Colin Greenwood, Ed O'Brien, and Philip Selway. They are widely considered one of the most influential bands of the last three decades.",
            members: [
                PrototypeMember(id: 101, name: "Thom Yorke", isActive: true),
                PrototypeMember(id: 102, name: "Jonny Greenwood", isActive: true),
                PrototypeMember(id: 103, name: "Colin Greenwood", isActive: true),
                PrototypeMember(id: 104, name: "Ed O'Brien", isActive: true),
                PrototypeMember(id: 105, name: "Philip Selway", isActive: true)
            ]
        ),
        PrototypeArtist(
            id: 2,
            name: "Daft Punk",
            profile: "Daft Punk were a French electronic music duo formed in Paris in 1993. They were composed of Guy-Manuel de Homem-Christo and Thomas Bangalter. The duo disbanded in February 2021.",
            members: [
                PrototypeMember(id: 201, name: "Guy-Manuel de Homem-Christo", isActive: false),
                PrototypeMember(id: 202, name: "Thomas Bangalter", isActive: false)
            ]
        ),
        PrototypeArtist(
            id: 3,
            name: "David Bowie",
            profile: "David Robert Jones, known professionally as David Bowie, was an English singer, songwriter, and actor. He was a leading figure in the music industry and is considered one of the most influential musicians of the 20th century.",
            members: []
        ),
        PrototypeArtist(
            id: 4,
            name: "Björk",
            profile: "Björk Guðmundsdóttir is an Icelandic singer, songwriter, record producer, actress, and DJ. She has gained worldwide critical acclaim and is known for her wide-ranging musical style.",
            members: []
        ),
        PrototypeArtist(
            id: 5,
            name: "The Beatles",
            profile: "The Beatles were an English rock band formed in Liverpool in 1960. They are widely regarded as the greatest and most influential music band in history. Their catalogue of songs is considered among the finest ever recorded.",
            members: [
                PrototypeMember(id: 501, name: "John Lennon", isActive: false),
                PrototypeMember(id: 502, name: "Paul McCartney", isActive: true),
                PrototypeMember(id: 503, name: "George Harrison", isActive: false),
                PrototypeMember(id: 504, name: "Ringo Starr", isActive: true)
            ]
        ),
        PrototypeArtist(
            id: 6,
            name: "Pink Floyd",
            profile: "Pink Floyd were an English rock band formed in London in 1965. They are known for their progressive and psychedelic music, philosophical lyrics, and elaborate live shows.",
            members: [
                PrototypeMember(id: 601, name: "Syd Barrett", isActive: false),
                PrototypeMember(id: 602, name: "Roger Waters", isActive: true),
                PrototypeMember(id: 603, name: "David Gilmour", isActive: true),
                PrototypeMember(id: 604, name: "Nick Mason", isActive: true),
                PrototypeMember(id: 605, name: "Richard Wright", isActive: false)
            ]
        ),
        PrototypeArtist(
            id: 7,
            name: "Aphex Twin",
            profile: "Richard David James, known as Aphex Twin, is an Irish-British musician and composer. He is widely considered a pioneer of electronic music, particularly in the genres of ambient techno and IDM.",
            members: []
        ),
        PrototypeArtist(
            id: 8,
            name: "Nine Inch Nails",
            profile: "Nine Inch Nails is an American industrial rock band formed in Cleveland, Ohio. Trent Reznor is the band's primary member, founder, and creative force.",
            members: [
                PrototypeMember(id: 801, name: "Trent Reznor", isActive: true),
                PrototypeMember(id: 802, name: "Atticus Ross", isActive: true)
            ]
        )
    ]

    static let releases: [PrototypeRelease] = [
        PrototypeRelease(id: 1001, title: "OK Computer", year: 1997, genres: ["Rock"], labels: ["Parlophone"], type: "master"),
        PrototypeRelease(id: 1002, title: "Kid A", year: 2000, genres: ["Electronic", "Rock"], labels: ["Parlophone"], type: "master"),
        PrototypeRelease(id: 1003, title: "The Bends", year: 1995, genres: ["Rock"], labels: ["Parlophone"], type: "master"),
        PrototypeRelease(id: 1004, title: "Pablo Honey", year: 1993, genres: ["Rock"], labels: ["Parlophone"], type: "master"),
        PrototypeRelease(id: 1005, title: "Amnesiac", year: 2001, genres: ["Electronic", "Rock"], labels: ["Parlophone"], type: "master"),
        PrototypeRelease(id: 1006, title: "Hail to the Thief", year: 2003, genres: ["Rock"], labels: ["Parlophone"], type: "master"),
        PrototypeRelease(id: 1007, title: "In Rainbows", year: 2007, genres: ["Rock"], labels: ["XL Recordings"], type: "master"),
        PrototypeRelease(id: 1008, title: "The King of Limbs", year: 2011, genres: ["Electronic", "Rock"], labels: ["XL Recordings"], type: "master"),
        PrototypeRelease(id: 1009, title: "A Moon Shaped Pool", year: 2016, genres: ["Art Rock"], labels: ["XL Recordings"], type: "master")
    ]
}
