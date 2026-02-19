import Foundation

class SongLibrary {
    static let shared = SongLibrary()
    
    let samples: [Song] = [
        // MARK: - Top 10
        Song(title: "Can't Help Falling In Love", artist: "Elvis Presley", rawContent: """
        [C] Wise [Em] men [Am] say only [F] fools [C] rush [G] in
        But [F] I [G] can't [Am] help [F] falling in [C] love [G] with [C] you
        [C] Shall [Em] I [Am] stay? Would [F] it [C] be a [G] sin?
        If [F] I [G] can't [Am] help [F] falling in [C] love [G] with [C] you
        
        [Em] Like a [B7] river [Em] flows [B7] surely to the [Em] sea
        [B7] Darling [Em] so it [Am] goes, [Dm] some things [G] are meant to [C] be
        
        [C] Take [Em] my [Am] hand, quote [F] take my [C] whole life [G] too
        For [F] I [G] can't [Am] help [F] falling in [C] love [G] with [C] you
        For [F] I [G] can't [Am] help [F] falling in [C] love [G] with [C] you
        """),
        
        Song(title: "Riptide", artist: "Vance Joy", rawContent: """
        [Am] I was scared of [G] dentists and the [C] dark
        [Am] I was scared of [G] pretty girls and [C] starting conversations
        Oh, [Am] all my [G] friends are turning [C] green
        You're the [Am] magician's [G] assistant in their [C] dream
        
        [Am] Oh, [G] and they [C] come unstuck
        
        [Am] Lady, [G] running down to the [C] riptide
        Taken away to the [Am] dark side [G] I wanna be your [C] left hand man
        [Am] I love you [G] when you're singing that [C] song and
        [Am] I got a lump in my [G] throat 'cause you're [C] gonna sing the words wrong
        
        [Am] There's this movie [G] that I think you'll [C] like
        This [Am] guy decides to [G] quit his job and [C] heads to New York City
        This [Am] cowboy's [G] running from him[C]self
        And [Am] she's been living [G] on the highest [C] shelf
        
        [Am] Oh, [G] and they [C] come unstuck
        
        [Am] Lady, [G] running down to the [C] riptide
        Taken away to the [Am] dark side [G] I wanna be your [C] left hand man
        [Am] I love you [G] when you're singing that [C] song and
        [Am] I got a lump in my [G] throat 'cause you're [C] gonna sing the words wrong
        """),
        
        Song(title: "Somewhere Over The Rainbow", artist: "Israel Kamakawiwo'ole", rawContent: """
        [C] Somewhere [Em] over the rainbow [F] way up [C] high
        [F] And the [C] dreams that you dream of [G] once in a lulla[Am]by [F]
        
        [C] Somewhere [Em] over the rainbow [F] bluebirds [C] fly
        [F] And the [C] dreams that you dream of [G] dreams really do come [Am] true [F]
        
        Someday I'll [C] wish upon a star
        [G] Wake up where the clouds are far be[Am]hind [F] me
        Where [C] trouble melts like lemon drops
        [G] High above the chimney tops that's [Am] where you'll [F] find me
        
        [C] Somewhere [Em] over the rainbow [F] bluebirds [C] fly
        [F] And the [C] dreams that you dare to [G] why oh why can't [Am] I [F]
        """),
        
        Song(title: "I'm Yours", artist: "Jason Mraz", rawContent: """
        [C] Well you done done me and you bet I felt it
        I [G] tried to be chill but you're so hot that I melted
        I [Am] fell right through the cracks
        And now I'm [F] trying to get back
        
        Before the [C] cool done run out I'll be giving it my bestest
        And [G] nothing's gonna stop me but divine intervention
        I [Am] reckon it's again my turn to [F] win some or learn some
        
        [C] But I won't hesitate no [G] more, no more
        It [Am] cannot wait, I'm [F] yours
        
        [C] Well open up your mind and see like me
        [G] Open up your plans and damn you're free
        [Am] Look into your heart and you'll find that the [F] sky is yours
        """),
        
        Song(title: "Hey Soul Sister", artist: "Train", rawContent: """
        Your [C] lipstick stains [G] on the front lobe of my [Am] left side brain [F]
        I [C] knew I wouldn't for[G]get you and so I [Am] went and let you [F] [G] blow my mind
        
        Your [C] sweet moonbeam [G] the smell of you in every [Am] single dream I [F] dream
        I [C] knew when we col[G]lided you're the one I have de[Am]cided who's one of my [F] kind
        
        [F] Hey soul [G] sister [C] ain't that [G] mister [F] mister on the [G] radio stereo
        [C] The way you move ain't [G] fair you know
        [F] Hey soul [G] sister [C] I don't want to [G] miss a single [F] thing you [G] do [C] tonight
        """),
        
        Song(title: "Let It Be", artist: "The Beatles", rawContent: """
        When I [C] find myself in [G] times of trouble [Am] Mother Mary [F] comes to me
        [C] Speaking words of [G] wisdom, let it [F] be [C]
        And [C] in my hour of [G] darkness she is [Am] standing right in [F] front of me
        [C] Speaking words of [G] wisdom, let it [F] be [C]
        
        Let it [Am] be, let it [G] be, let it [F] be, let it [C] be
        [C] Whisper words of [G] wisdom, let it [F] be [C]
        
        And [C] when the broken [G] hearted people [Am] living in the [F] world agree
        [C] There will be an [G] answer, let it [F] be [C]
        For [C] though they may be [G] parted there is [Am] still a chance that [F] they will see
        [C] There will be an [G] answer, let it [F] be [C]
        """),
        
        Song(title: "Imagine", artist: "John Lennon", rawContent: """
        [C] Imagine there's no [Cmaj7] heaven [F]
        [C] It's easy if you [Cmaj7] try [F]
        [C] No hell be[Cmaj7]low us [F]
        [C] Above us only [Cmaj7] sky [F]
        [F] Imagine [Am] all the [Dm] people [F] [G] living for to[G7]day
        
        [C] Imagine there's no [Cmaj7] countries [F]
        [C] It isn't hard to [Cmaj7] do [F]
        [C] Nothing to kill or [Cmaj7] die for [F]
        [C] And no religion [Cmaj7] too [F]
        [F] Imagine [Am] all the [Dm] people [F] [G] living life in [G7] peace
        
        [F] You may [G] say I'm a [C] dreamer [E7]
        [F] But I'm [G] not the only [C] one [E7]
        [F] I hope some[G]day you'll [C] join us [E7]
        [F] And the [G] world will [C] be as one
        """),
        
        Song(title: "Hallelujah", artist: "Leonard Cohen", rawContent: """
        I [C] heard there was a [Am] secret chord
        That [C] David played and it [Am] pleased the lord
        But [F] you don't really [G] care for music [C] do you [G]
        It [C] goes like this the [F] fourth the [G] fifth
        The [Am] minor fall and the [F] major lift
        The [G] baffled king com[E7]posing halle[Am]lujah
        
        Halle[F]lujah, Halle[Am]lujah, Halle[F]lujah, Halle[C]lu[G]jah [C]
        
        Your [C] faith was strong but you [Am] needed proof
        You [C] saw her bathing [Am] on the roof
        Her [F] beauty in the [G] moonlight over[C]threw you [G]
        She [C] tied you to a [F] kitchen [G] chair
        She [Am] broke your throne, and she [F] cut your hair
        And [G] from your lips she [E7] drew the halle[Am]lujah
        """),
        
        Song(title: "Three Little Birds", artist: "Bob Marley", rawContent: """
        [C] Don't worry about a thing
        'Cause [F] every little thing gonna be all [C] right
        Singin' [C] don't worry about a thing
        'Cause [F] every little thing gonna be all [C] right
        
        Rise up this [C] mornin', smiled with the [G] risin' sun
        Three little [C] birds pitch by my [F] doorstep
        Singin' [C] sweet songs of melodies [G] pure and true
        Sayin', [F] this is my message to [C] you
        """),
        
        Song(title: "Stand By Me", artist: "Ben E. King", rawContent: """
        When the [C] night has come [Am] and the land is dark
        And the [F] moon is the [G] only light we'll [C] see
        No I [C] won't be afraid [Am] no I won't be afraid
        Just as [F] long as you [G] stand, stand by [C] me
        
        So [C] darling, darling [Am] stand by me, oh [F] stand by [G] me
        Oh [C] stand, stand by me, stand by me
        
        If the [C] sky that we look upon [Am] should tumble and fall
        Or the [F] mountain should [G] crumble to the [C] sea
        I won't [C] cry, I won't cry [Am] no I won't shed a tear
        Just as [F] long as you [G] stand, stand by [C] me
        """),
        
        // MARK: - Classics
        Song(title: "What a Wonderful World", artist: "Louis Armstrong", rawContent: """
        I see [C] trees of [Em] green, [F] red roses [Em] too
        [Dm] I see them [C] bloom, [E7] for me and [Am] you
        And I [F] think to my [C] self, [Dm] what a [G7] wonderful [C] world
        
        I see [C] skies of [Em] blue, and [F] clouds of [Em] white
        The [Dm] bright blessed [C] day, the [E7] dark sacred [Am] night
        And I [F] think to my [C] self, [Dm] what a [G7] wonderful [C] world
        """),
        
        Song(title: "La Vie En Rose", artist: "Edith Piaf", rawContent: """
        Hold me [G] close and hold me [Gmaj7] fast
        The magic spells you [Am] cast
        This is La Vie En [D] Rose
        
        When you kiss me heaven [D7] sighs
        And though I close my [G] eyes
        I see La Vie En [Gmaj7] Rose
        
        When you press me to your [Em] heart
        I'm in a world a[Am]part
        A world where roses [D] bloom
        """),
        
        Song(title: "Moon River", artist: "Audrey Hepburn", rawContent: """
        [G] Moon [Em] River, [C] wider than a [G] mile
        I'm [C] crossing you in [G] style some [Am] day
        Oh [Em] dream [G] maker, you [C] heart [G/B] breaker
        Wher[Em]ever you're [A7] goin', I'm [Am7] goin' your [D7] way
        """),

        Song(title: "Fly Me To The Moon", artist: "Frank Sinatra", rawContent: """
        [Am] Fly me to the [Dm] moon
        And let me [G7] play among the [Cmaj7] stars
        [F] Let me see what [Dm] spring is like
        On [E7] Jupiter and [Am] Mars
        
        In [Dm] other words, [G7] hold my [Cmaj7] hand
        In [Dm] other words, [G7] baby, [C] kiss me
        """),
        
        Song(title: "Dream a Little Dream of Me", artist: "The Mamas & The Papas", rawContent: """
        [C] Stars [B7] shining bright [Ab] above [G] you
        [C] Night [B7] breezes seem to [A] whisper "I love you"
        [F] Birds singing in the [Fm] sycamore tree
        [C] Dream a little [Ab] dream [G] of [C] me
        """),
        
        // MARK: - Pop/Rock
        Song(title: "Count on Me", artist: "Bruno Mars", rawContent: """
        [C] If you ever [Em] find yourself stuck in the [Am] middle of the [G] sea
        [F] I'll sail the [C] world to [Em] find [G] you
        [C] If you ever [Em] find yourself lost in the [Am] dark and you [G] can't see
        [F] I'll be the [C] light to [Em] guide [G] you
        
        [Dm] Find out what we're [Em] made of
        [F] When we are called to help our friends in [G] need
        
        [C] You can count on [Em] me like 1 2 [Am] 3 I'll be [G] there
        And [F] I know when I [C] need it I can [Em] count on you like 4 3 [Am] 2
        """),
        
        Song(title: "Love Yourself", artist: "Justin Bieber", rawContent: """
        [C] For all the [G] times that you [Am] rain on my pa-[F] rade
        And all the [C] clubs you get in [G] using my [C] name
        You think you [G] broke my heart [Am] oh girl for goodness [F] sake
        You think I'm [C] crying on my [G] own well I [C] ain't
        
        And I [Am] didn't wanna [F] write a song cause I [C] didn't want anyone [G] thinking I still care
        I [Am] don't but [F] you still hit my phone up
        """),
        
        Song(title: "Perfect", artist: "Ed Sheeran", rawContent: """
        [C] I found a [Am] love for [F] me
        Darling just [G] dive right in, and follow my [C] lead
        Well I found a [Am] girl beauti-[F] ful and sweet
        I never [G] knew you were the someone waiting for [C] me
        """),
        
        Song(title: "Just the Way You Are", artist: "Bruno Mars", rawContent: """
        [C] Oh her eyes her eyes make the [Am] stars look like they're not shining
        [F] Her hair her hair falls [C] perfectly without her trying
        [C] She's so beautiful and I [Am] tell her every day
        """),
        
        Song(title: "Ho Hey", artist: "The Lumineers", rawContent: """
        [C] I've been trying to [F] do it [C] right
        [C] I've been living a [F] lonely [C] life
        [C] I've been sleeping [F] here in [C] stead
        [Am] I've been sleeping [G] in my [C] bed
        """),
        
        // MARK: - Disney/Fun
        Song(title: "Hakuna Matata", artist: "The Lion King", rawContent: """
        [F] Hakuna Ma-[C] tata, what a wonderful [F] phrase [D7]
        [F] Hakuna Ma-[C] tata, ain't no passing [G7] craze
        [Am] It means no [F] worries [D7] for the rest of your [G] days
        [C] It's our [G] problem-free [C] philosophy
        [F] Ha-[G] kuna Ma-[C] tata
        """),
        
        Song(title: "You've Got a Friend in Me", artist: "Randy Newman", rawContent: """
        [C] You've [G] got a [C] friend in [C7] me
        [F] You've got a [F#dim] friend in [C] me
        [F] When the [C] road looks [E7] rough [Am] ahead
        And you're [F] miles and [C] miles from your [E7] nice warm [Am] bed
        [F] You just re-[C] member what your [E7] old pal [Am] said
        Boy [D7] you've got a [G7] friend in [C] me
        """),
        
        Song(title: "A Whole New World", artist: "Aladdin", rawContent: """
        [C] I can [C7] show you the [F] world
        [C] Shining [C7] shimmering [F] splendid
        [Em] Tell me [E7] princess now [Am] when did
        You [F] last let your [G] heart de-[C] cide
        
        [C] I can [C7] open your [F] eyes
        [C] Take you [C7] wonder by [F] wonder
        [Em] Over [E7] sideways and [Am] under
        On a [F] magic [G] carpet [C] ride
        """),
        
        Song(title: "Lava", artist: "Pixar", rawContent: """
        [C] A long [G7] long time ago [F] there was a vol-[C] cano
        [F] Living all a-[C] lone in the [G7] middle of the [C] sea
        [C] He sat [G7] high above his bay [F] watching all the couples [C] play
        [F] And wishing that [C] he had [G7] someone [C] too
        """),
        
        Song(title: "How Far I'll Go", artist: "Moana", rawContent: """
        [C] I've been [Dm] staring at the edge of the [Am] water
        Long as I [F] can remember, never really knowing [C] why
        [C] I wish I [Dm] could be the perfect [Am] daughter
        But I come back to the [F] water, no matter how hard I [C] try
        """),
        
        // MARK: - Oldies/Folk
        Song(title: "Blowin' in the Wind", artist: "Bob Dylan", rawContent: """
        [C] How many [F] roads must a [C] man walk down
        Before you [F] call him a [C] man
        [C] How many [F] seas must a [C] white dove sail
        Before she [F] sleeps in the [G7] sand
        [C] The answer my [F] friend is [G7] blowin' in the [C] wind
        The [F] answer is [G7] blowin' in the [C] wind
        """),
        
        Song(title: "Bad Moon Rising", artist: "CCR", rawContent: """
        [D] I see the [A] bad [G] moon [D] rising
        [D] I see [A] trouble [G] on the [D] way
        [D] I see [A] earth-[G] quakes and [D] lightnin'
        [D] I see [A] bad [G] times [D] today
        """),
        
        Song(title: "Ring of Fire", artist: "Johnny Cash", rawContent: """
        [G] Love is a [C] burning [G] thing
        And it makes a [D] fiery [G] ring
        Bound by [C] wild de-[G] sire
        I fell into a [D] ring of [G] fire
        
        [D] I fell into a [C] burning ring of [G] fire
        I went [D] down down down and the [C] flames went [G] higher
        """),
        
        Song(title: "Sound of Silence", artist: "Simon & Garfunkel", rawContent: """
        Hello [Am] darkness my old [G] friend
        I've come to [Am] talk with you again
        Because a [C] vision softly [F] creep-[C] ing
        Left its seeds while I was [F] sleep-[C] ing
        And the [F] vision that was planted in my [C] brain
        Still re-[Am] mains... within the [G] sound of [Am] silence
        """),
        
        Song(title: "Lean on Me", artist: "Bill Withers", rawContent: """
        [C] Sometimes in our [F] lives we all have [C] pain
        We all have [Em] sor-[G] row
        [C] But if we are [F] wise we know that [C] there's
        Always [G] to-[C] morrow
        
        [C] Lean on me, when you're not [F] strong
        And I'll be your [C] friend, I'll help you carry [Em] on [G]
        [C] For it won't be [F] long, 'til I'm gonna [C] need
        Somebody to [G] lean [C] on
        """),
        
        // MARK: - Anthems
        Song(title: "Sweet Caroline", artist: "Neil Diamond", rawContent: """
        [C] Where it began, [F] I can't begin to knowing
        [C] But then I know it's growing [G] strong
        [C] Was in the spring [F] and spring became the summer
        [C] Who'd have believed you'd come a-[G] long
        
        [C] Hands, [Am] touching hands
        [G] Reaching out, [F] touching me, touching [G] you
        
        [C] Sweet Caro-[F] line
        Good times never seemed so [G] good
        [C] I've been in-[F] clined
        To believe they never [G] would
        """),
        
        Song(title: "Don't Stop Believin'", artist: "Journey", rawContent: """
        [C] Just a small town girl, [G] living in a [Am] lonely world
        [F] She took the [C] midnight train going [G] any-[Em] where [F]
        [C] Just a city boy, [G] born and raised in [Am] South Detroit
        [F] He took the [C] midnight train going [G] any-[Em] where [F]
        
        [C] Don't stop [G] believin'
        [Am] Hold on to that [F] feelin'
        [C] Streetlights [G] people [Em] oh [F]
        """),
        
        Song(title: "I Will Survive", artist: "Gloria Gaynor", rawContent: """
        [Am] At first I was afraid I was [Dm] petrified
        Kept thinking [G] I could never live without you [C] by my side
        But then I [F] spent so many nights thinking [Bm7b5] how you did me wrong
        And I grew [E7] strong, and I learned how to get a-[Am] long
        """),
        
        Song(title: "Hotel California", artist: "Eagles", rawContent: """
        [Am] On a dark desert highway [E7] cool wind in my hair
        [G] Warm smell of colitas [D] rising up through the air
        [F] Up ahead in the distance [C] I saw a shimmering light
        [Dm] My head grew heavy and my sight grew dim
        [E7] I had to stop for the night
        
        [F] Welcome to the Hotel Cali-[C] fornia
        [E7] Such a lovely place, such a lovely [Am] face
        """),
         
        Song(title: "Wonderwall", artist: "Oasis", rawContent: """
        [Em] Today is [G] gonna be the day that they're [D] gonna throw it back to [A] you
        [Em] By now you [G] should've somehow rea-[D] lized what you gotta [A] do
        [Em] I don't believe that [G] anybody [D] feels the way I [A] do about you [C] now [D] [A]
        
        [C] Because [D] maybe [Em]
        [C] You're gonna [D] be the one that [Em] saves me
        [C] And after [D] all
        [C] You're my wonder-[Em] wall
        """)
    ]
}
