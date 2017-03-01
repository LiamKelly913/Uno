//
//  GameViewController.swift
//  Uno
//
//  Created by Liam Kelly on 7/12/16.
//  Copyright © 2016 LiamKelly. All rights reserved.
//

import UIKit


class GameViewController: UIViewController {
    //MARK: variables
    

    @IBOutlet weak var playedCard:UIImageView!
    @IBOutlet weak var scroll:UIScrollView!
    @IBOutlet weak var drawCard:UIButton!
    @IBOutlet weak var playAgainButton:UIButton!
    
    //TEXTFIELD FOR TESTING
    @IBOutlet weak var textField:UITextField!
    
    //TEST VARIABLES
    
    @IBOutlet weak var drawCardHeight: NSLayoutConstraint!
    @IBOutlet weak var drawCardWidth: NSLayoutConstraint!
    @IBOutlet weak var currentCardHeight: NSLayoutConstraint!
    @IBOutlet weak var currentCardWidth: NSLayoutConstraint!
    
    
    
    
    let imageToAnimate = UIImageView()
    
    var enemyImages:[UIImageView] = []
    var enemyDrawImages:[UIButton] = []
    var wildImages:[UIButton] = []
    
    var iWidth:CGFloat!
    var iHeight:CGFloat!
    var xPos:CGFloat = 0
    var buffer:CGFloat!
    var enemyBuffer:CGFloat!
    
    var numberOfOpponents:Int!
    var players:[Player] = []
    var currentCard:Card = Card()
    
    
    //the worst variable known to man
    var madeChoice:Bool = false
    
    var randDeck:[String] = []
    let numberArray = [1,2,3,4,5,6,7,8,9]
    let colorArray = ["Red","Gre","Blu","Yel"]
    let specialArray = ["draw2","reverse","skip"]
    let wild = ["Wild","Wilddraw4"]
    var deck:[Card] = []
    var oldDeck:[Card] = []
    var reverse = false
    var currentPlayer: Int = 0
    
    // Used to determine player iteration
    var skipped:Bool = false
    var wasDraw:Bool = false
    var wasReverse:Bool = false
    
    
    var didFinishAnimation = false
    var wasWildDraw4 = false
    
    //TODO: Fix wild bug for not updating current card image when 
    //      computer plays and chooses wild color
    //TODO: Fix memory leak
    //TODO: Ask for smaller images
    

    override func viewDidLoad() {
        setup()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateStartingHand()
    }
    
    
    
    //MARK: Setup
    
    func setup() {
        calculateCardSizes()
        setupUI()
        createOpponents()
        generateEnemyUI(numberOfOpponents)
        generateCards()
        startingCards()
        print(deck.count)
        edit(scroll)
        hideDrawOptions()
        setupWildCards()
        textField.delegate = self
        textField.isHidden = true
    }
    
    // set image/button heights and widths
    func setupUI() {
        drawCardHeight.constant = iHeight
        drawCardWidth.constant = iWidth
        currentCardWidth.constant = iWidth
        currentCardHeight.constant = iHeight
        imageToAnimate.frame.size.width = iWidth
        imageToAnimate.frame.size.height = iHeight
        drawCard.adjustsImageWhenDisabled = false
        playAgainButton.isHidden = true
    }
    
    // set height/width based on screen size
    func calculateCardSizes() {
        let quarterView = 0.25*(self.view.frame.width)
        enemyBuffer = 0.0375*quarterView
        buffer = enemyBuffer + 4
        iWidth = 0.925*quarterView
        iHeight = (1.45)*iWidth
    }
    
    // Creates number of opponents based on prevoius screen
    func createOpponents() {
        // User will be referenced as the first index in the player array
        var index = 0
        for _ in 0...numberOfOpponents {
            let newPlayer:Player = Player()
            newPlayer.index = index
            players.append(newPlayer)
            index+=1
        }
        print(players)
    }
    
    // Returns a card as a specified type
    func createCard(_ type:String) -> Card {
        let card = Card()
        card.type = type
        return card
    }
    
    // Generate all cards in the deck, append to the deck array
    func generateCards() {
        for color in colorArray {
            deck.append(createCard(color + "0"))
            for number in numberArray {
                for _ in 1...2 {
                    deck.append(createCard(color + String(number)))
                }
            }
            for card in specialArray {
                for _ in 1...2 {
                    deck.append(createCard(color + card))
                }
            }
            for card in wild {
                deck.append(createCard(card))
            }
        }
        print("There are \(deck.count) cards")
    }
    
    // add starting cards in user's hand to the view
    func updateStartingHand() {
        for card in players[0].hand {
            let cardButton = card.image
            setHandConstraints(cardButton)
            xPos += buffer
            card.xVal = xPos
            cardButton.adjustsImageWhenHighlighted = false
            cardButton.frame.origin.x = xPos
            cardButton.titleLabel!.text = card.type
            cardButton.setImage(UIImage(named: card.type), for: UIControlState())
            scroll.addSubview(cardButton)
            xPos += (iWidth + buffer)
            scroll.contentSize.width = xPos
        }
    }
    
    // Give each player 7 cards, and flip over the first card to play against
    func startingCards() {
        for player in players {
            for _ in 1...7 {
                giveCard(player)
            }
            print("Hand for Player:")
            for card in player.hand {
                print((card.type))
            }
            print("-----------------")
            print()
        }
        var startingCard = Card()
        let r = randIndex(deck)
        startingCard = deck[r]
        oldDeck.append(startingCard)
        deck.remove(at: r)
        currentCard = startingCard
        playedCard.image = UIImage(named: currentCard.type)
        print("\(currentCard.type) Is the current card")
        print()
    }
    
    // Creates the enemy hand images as well as the overlay buttons for a draw card to target
    func generateEnemyUI(_ num:Int) {
        let divide = (Double(self.view.frame.width))/Double(num+1)
        let quarterDivide = (Double(self.view.frame.width))/Double(num)
        var xPos = CGFloat(divide)
        if(num == 4) {
            xPos = CGFloat(quarterDivide) + buffer
        }
        for _ in 1...num {
            // Create the button for draw cards
            let choiceButton = UIButton()
            choiceButton.frame.size.height = iHeight
            choiceButton.frame.size.width = iWidth
            choiceButton.backgroundColor = UIColor.clear
            choiceButton.layer.cornerRadius = 5
            choiceButton.layer.borderWidth = 3
            choiceButton.layer.borderColor = UIColor.blue.cgColor
            view.addSubview(choiceButton)
            choiceButton.addTarget(self, action: #selector(playerGivesCards(_:)), for: UIControlEvents.touchUpInside)
            
            let image = UIImageView()
            setImageConstraints(image)
            if(num == 4) {
                image.frame.origin.x = xPos - buffer - (iWidth)
                xPos += CGFloat(quarterDivide)
            } else {
                image.frame.origin.x = xPos - (iWidth/2)
                xPos += CGFloat(divide)
            }
            enemyImages.append(image)
            image.frame.origin.y = 40
            image.image = UIImage(named: "CardBack")
            
            // Set draw card button equal to current enemy frame
            choiceButton.frame.origin = image.frame.origin
            enemyDrawImages.append(choiceButton)
            
            self.view.addSubview(image)
            
        }
    }

    
    // Create wild cards and add action for user selection
    func setupWildCards() {
        for color in colorArray {
            let choice = UIButton()
            choice.adjustsImageWhenHighlighted = false
            choice.frame.size.width = iWidth
            choice.frame.size.height = iHeight
            choice.setImage(UIImage(named: color), for: UIControlState())
            choice.addTarget(self, action: #selector(playerChoosesWild(_:)), for: UIControlEvents.touchUpInside)
            wildImages.append(choice)
            print(iWidth)
            print(iHeight)
        }
        resetWildCards()
    }
    
    // Put the wild draw cards back into their original positions
    func resetWildCards() {
        let x1:CGFloat = self.view.frame.width/2  - buffer - iWidth
        let x2:CGFloat = self.view.frame.width/2 + buffer
        let y1:CGFloat = self.view.frame.height/2 - buffer - iHeight
        let y2:CGFloat = self.view.frame.height/2 + buffer
        
        wildImages[0].frame.origin = CGPoint(x: x1, y: y1)
        wildImages[1].frame.origin = CGPoint(x: x1, y: y2)
        wildImages[2].frame.origin = CGPoint(x: x2, y: y1)
        wildImages[3].frame.origin = CGPoint(x: x2, y: y2)
    }
    
    //MARK: UI Updates
    
    func edit(_ view: UIScrollView) {
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 3
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.green.cgColor
    }
    
    func removeEdit(_ view: UIScrollView) {
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 0
        view.layer.borderWidth = 0
        view.layer.borderColor = nil
    }
    
    func highlightOpponent() {
        let view = enemyImages[currentPlayer-1]
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.red.cgColor
    }
    
    func removeHighlight(_ previousPlayer:Int) {
        let view = enemyImages[previousPlayer-1]
        view.layer.cornerRadius = 0
        view.layer.borderWidth = 0
        view.layer.borderColor = nil
    }
    
    func setConstraints(_ button:UIButton) {
        button.frame.size.width = iWidth
        button.frame.size.height = iHeight
    }
    
    func setHandConstraints(_ button:UIButton) {
        button.frame.size.width = iWidth
        button.frame.size.height = iHeight
        button.frame.origin.y = (scroll.frame.size.height-iHeight)/2
        button.addTarget(self, action: #selector(chooseUserCard(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func setImageConstraints(_ image:UIImageView) {
        image.frame.size.width = iWidth
        image.frame.size.height = iHeight
    }
    
    
    func showDrawOptions() {
        for image in enemyDrawImages {
            view.addSubview(image)
        }
    }
    
    func hideDrawOptions() {
        for image in enemyDrawImages {
            image.removeFromSuperview()
        }
    }
    
    func showWildOptions() {
        drawCard.isEnabled = false
        for image in wildImages {
            view.addSubview(image)
        }
    }
    
    // Hides all but the selected options for Wild Cards,
    // selected option is animated and then hidden in another method
    func hideWildOptions(_ index:Int) {
        var current = 0
        for _ in wildImages {
            if current != index {
                wildImages[current].removeFromSuperview()
            }
            current+=1
        }
        drawCard.isEnabled = true
    }
    
    // Removes the selected card from view and hand, animates
    // all other cards shifting over to take its place
    func removeCard(_ sender: UIButton, choice: Card) {
        xPos -= (iWidth + 2*buffer)
        var index = 0
        var targetIndex = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.scroll.contentSize.width = self.xPos
            for card in self.players[0].hand {
                if(card.xVal == choice.xVal) {
                    targetIndex = index
                }
                if card.xVal >= choice.xVal {
                    let endPoint = CGFloat(card.image.frame.origin.x - (self.iWidth + 2*self.buffer))
                    card.image.frame.origin.x = endPoint
                    card.xVal = card.image.frame.origin.x
                }
                index+=1
            }
            }, completion: { finished in
                self.players[0].hand.remove(at: targetIndex)

        })
    }
    
    //TODO: Make this animated
    // adds cards to user's hand that may have been given but enemy draw cards
    func updateUserHand() {
        print("Calling update user hand")
        for card in players[0].hand {
            if(card.xVal == 0) {
                setHandConstraints(card.image)
                xPos += buffer
                card.xVal = xPos
                card.image.adjustsImageWhenHighlighted = false
                card.image.frame.origin.x = xPos
                card.image.titleLabel!.text = card.type
                card.image.setImage(UIImage(named: card.type), for: UIControlState())
                scroll.addSubview(card.image)
                xPos += (iWidth + buffer)
                scroll.contentSize.width = xPos
            }
        }
    }
    
    // animates a card from one point to another
    func animateCard(_ startPoint: CGPoint, endPoint: CGPoint, image:UIImage) {
        imageToAnimate.frame.origin = startPoint
        imageToAnimate.image = image
        self.view.addSubview(imageToAnimate)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.imageToAnimate.frame.origin = endPoint
                }, completion: { finished in
                    self.playedCard.image = image
                    self.imageToAnimate.removeFromSuperview()
                    self.didFinishAnimation = true
            })
        }
    }
    
    // called when game is done
    @IBAction func playAgain(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: Draw Card   
    
    // take card from deck, put in user's hand
    @IBAction func addCard(_ sender: UIButton) {
        if(currentPlayer ==  0) {
            
            // Add card to player array
            giveCard(players[0])
            let card = players[0].hand[players[0].hand.count-1]
            
            // Setup for the button
            let cardButton = card.image
            setHandConstraints(cardButton)
            cardButton.adjustsImageWhenHighlighted = false
            
            xPos += buffer

            var endPoint = CGPoint(x: (view.frame.width - (buffer + iWidth)), y: cardButton.frame.origin.y + scroll.frame.origin.y)
            // change the endpoint of animation if there are only 1 or 2 cards left
            if(players[0].hand.count < 4) {
                endPoint = CGPoint(x: xPos, y: cardButton.frame.origin.y + scroll.frame.origin.y)
            }
            
            card.xVal = xPos
            cardButton.frame.origin.x = xPos
            print("\(card.type) is now in your hand")
            cardButton.titleLabel!.text = card.type
            xPos += (iWidth + buffer)
            cardButton.setImage(UIImage(named: card.type), for: UIControlState())
            
            scroll.contentSize.width = xPos
            if(xPos > self.view.frame.width) {
                let offset:CGPoint = CGPoint(x: (xPos - self.view.frame.width), y: 0)
                scroll.setContentOffset(offset, animated: true)
            }
            // Set the image to animate's origin and image
            imageToAnimate.frame.origin = drawCard.frame.origin
            imageToAnimate.image = UIImage(named: card.type)
            view.addSubview(imageToAnimate)
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.drawCard.isEnabled = false
                self.imageToAnimate.frame.origin = endPoint
                }, completion: { finished in
                    self.drawCard.isEnabled = true
                    self.scroll.addSubview(cardButton)
                    self.imageToAnimate.removeFromSuperview()
            })
        }
    }

    
    //MARK: Card logic
    
    //Returns a random index from a specified array
    func randIndex(_ deck:[Card]) -> Int {
        return Int(arc4random_uniform(UInt32(deck.count)))
    }
    
    // Give an individual card to a target player and remove it from the deck
    func giveCard(_ target:Player) {
        if(deck.count == 0) {
            deck = oldDeck
        }
        let r = randIndex(deck)
        target.hand.append(deck[r])
        target.hand[target.hand.count-1].index = target.hand.count-1
        deck.remove(at: r)
    }
    
    func canPlay(_ choice:Card) -> Bool {
        let currName = currentCard.type
        let choiceName = choice.type
        var playable = false
        if((firstLetter(choiceName) == firstLetter(currName)) || (firstLetter(choiceName) == "W") || firstLetter(currName) == "W") {
            playable = true
        } else if (isDraw(choiceName) && isDraw(currName) && checkLastLetter(choiceName, second: currName)) {
            playable = true
        } else if ((!isDraw(choiceName) && !isDraw(currName)) && checkLastLetter(choiceName, second: currName)) {
            playable = true
        }
        return playable
    }
    
    func isDraw(_ word:String) -> Bool {
        let last = String(word.characters.suffix(3))
        if(last == "aw4" || last == "aw2") {
            return true
        }
        else {
            return false
        }
    }
    
    func checkLastLetter(_ first: String, second: String) -> Bool {
        if (lastLetter(first) == lastLetter(second)) {
            return true
        } else {
            return false
        }
    }
    
    func firstLetter(_ string:String) -> String {
        return String(string.characters.prefix(1))
    }
    
    func lastLetter(_ string:String) -> String {
        return String(string.characters.suffix(1))
    }
    
    // Give 2 or 4 cards to a target player
    func giveCards(_ card:String, target:Int) {
        let targetPlayer = players[target]
        print("Giving cards to player \(target)")
        for _ in 1...2 {
            giveCard(targetPlayer)
            if(lastLetter(card) == "4") {
                giveCard(targetPlayer)
            }
        }
        let image = UIImageView()
        setImageConstraints(image)
        var endPoint = CGPoint()
        image.frame.origin = self.drawCard.frame.origin
        self.view.addSubview(image)
        image.image = UIImage(named: "CardBack")
        if target != 0 {
        endPoint = enemyImages[target-1].frame.origin
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    image.frame.origin = endPoint
                    }, completion: { finished in
                        print("Completed draw card animation")
                        image.removeFromSuperview()
                    })
            }
        }
    }
    
    
    // Chooses the player with the least cards in hand
    func chooseTarget(_ userIndex:Int) -> Int {
        var choice:Int!
        var index = 0
        var smallestHand = 200
        for _ in 0...players.count-1 {
            if (players[index].hand.count < smallestHand && index != userIndex) {
                choice = index
                smallestHand = players[index].hand.count
            }
            index+=1
        }
        return choice
    }
    
    func randomColor() -> String {
        let r = Int(arc4random_uniform(4))
        return colorArray[r]
    }
    
    
    func checkVictory() -> Bool {
        var victory = false
        for player in players {
            if(player.hand.count == 0) {
                victory = true
                print("Victory!!")
                var index = 0
                for player in players {
                    if (player.hand.count == 0 && index != 0){
                        enemyImages[index-1].removeFromSuperview()
                    }
                    index+=1
                }
            }
        }
        return victory
    }
    
    func victory() {
        playAgainButton.isHidden = false
    }
    
    //MARK: Player logic
    
    func chooseUserCard(_ sender: UIButton) {
        // specifying toView as nil defaults the coordinates to the window base coordinates
        let globalPoint = sender.superview?.convert(sender.frame.origin, to: nil)
        let choice:Card = Card()
        choice.xVal = sender.frame.origin.x
        choice.type = sender.titleLabel!.text!
        print("You attempted to play \(choice.type) against \(currentCard.type)")
        if(canPlay(choice) && currentPlayer == 0) {
            sender.removeFromSuperview()
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                DispatchQueue.main.async {
                    self.animateCard(globalPoint!, endPoint:self.playedCard.frame.origin, image: UIImage(named: choice.type)!)
                    self.playUserCard(choice)
                    self.removeCard(sender, choice: choice)
                    if(self.checkVictory()) {
                        self.victory()
                    }
                }
                while(!self.madeChoice){
                    // This while loop hurts my soul
                }
                self.nextTurn()
                self.madeChoice = false
                self.enemyTurn()
            }
            
            print("User is playing \(choice.type)")
        }
    }
    
    func playUserCard(_ choice:Card) {
        currentCard = choice
        oldDeck.append(choice)
        let type = choice.type
        let first = String(type.characters.prefix(1))
        if(isDraw(type) && first == "W") {
            if(numberOfOpponents == 1) {
                giveCards(type, target: 1)
            } else {
                wasWildDraw4 = true
            }
            showWildOptions()
        } else if(isDraw(type)) {
            wasDraw = true
            if(numberOfOpponents == 1) {
                giveCards(type, target: 1)
            } else {
                showDrawOptions()
            }
        } else if(first == "W") {
            showWildOptions()
        } else if(lastLetter(type) == "e") {
            wasReverse = true
            reverse = !reverse
            madeChoice = true
        } else if(lastLetter(type) == "p") {
            skipped = true
            madeChoice = true
        } else {
            madeChoice = true
        }
    }
    
    // action attached to the buttons hidden over enemy hands to be called on when a draw card is played
    func playerGivesCards(_ sender:UIButton) {
        var index = 1
        for player in enemyImages {
            if (sender.frame.origin == player.frame.origin) {
                giveCards(currentCard.type, target: index)
                madeChoice = true
                hideDrawOptions()
            }
            index+=1
        }
    }
    
    //TODO: Fix wild card animation
    // action attached to the generic wild colors when displayed
    func playerChoosesWild(_ sender:UIButton) {
        var index = 0
        for color in colorArray {
            if(sender.currentImage == UIImage(named: color)) {
                //TODO: animate card, set current card as this one
                hideWildOptions(index)
                print("The button is at \(sender.frame.origin)")
                print("The target position is at \(playedCard.frame.origin)")
                UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    sender.frame.origin = self.playedCard.frame.origin
                    }, completion: { finished in
                        sender.removeFromSuperview()
                        self.playedCard.image = UIImage(named: color)
                        print(color)
                        self.currentCard.type = color
                        if(self.wasWildDraw4) {
                            self.showDrawOptions()
                        } else {
                            self.madeChoice = true
                        }
                })
                
            }
            index+=1
        }
        resetWildCards()
    }
    
    // Set the next player to the proper index after user turn
    func nextTurn() {
        if numberOfOpponents == 1 {
            if skipped || wasReverse || wasDraw{
                skipped = false
                wasDraw = false
                wasReverse = false
            } else {
                currentPlayer = 1
            }
        }
        
        else if reverse {
            if skipped {
                currentPlayer = numberOfOpponents-1
                skipped = false
            } else {
                currentPlayer = numberOfOpponents
            }
        }
        
        else if !reverse {
            if skipped {
                currentPlayer = 2
                skipped = false
            } else {
                currentPlayer+=1
            }
        }
    }
    
    
    //MARK: Enemy logic

    // Checks the cards in the player's hand until a playable card is found
    func doMove(_ userIndex:Int) {
        var played = false
        let player = players[userIndex]
        var currentIndex = 0
        var didExhaust = false
        for card in player.hand {
            print("Player \(userIndex) is looking at \(card.type)")
            if(currentIndex == player.hand.count-1) {
                didExhaust = true
            }
            if(canPlay(card) && !played) {
                sleep(2)
                playEnemyCard(card, userIndex: userIndex,  choiceIndex: currentIndex)
                played = true
            }
            currentIndex+=1
        }
        // draws a card and attempts to play it if all previous cards weren't playable
        while(didExhaust && !played) {
            print("Enemy player is drawing a card")
            giveCard(player)
            
            //TODO: Animate card being given to specified player
//            let start:CGPoint = drawCard.frame.origin
//            let endPoint:CGPoint = enemyImages[userIndex-1].frame.origin
//            imageToAnimate.frame.origin = start
//            dispatch_async(dispatch_get_main_queue()) {
//                UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseInOut, animations: {
//                    self.imageToAnimate.frame.origin = endPoint
//                    
//                    }, completion: { finished in
//                        self.imageToAnimate.removeFromSuperview()
//                        sleep(1)
//                })
//            }
            let lastCard = player.hand[player.hand.count-1]
            if(canPlay(lastCard)) {
                sleep(2)
                playEnemyCard(lastCard, userIndex: userIndex, choiceIndex: currentIndex)
                played = true
                didExhaust = false
                print("Playing a card that was drawn")
            }
            currentIndex+=1
        }
        print("Current Card is now: \(currentCard.type)")
        print()
        print("------------------")
        print()
    }
    
    func playEnemyCard(_ choice:Card, userIndex:Int, choiceIndex:Int) {
        oldDeck.append(choice)
        players[userIndex].hand.remove(at: choiceIndex)
        currentCard = choice
        print("|---Player \(userIndex) is playing \(choice.type)---|")
        let card = choice.type
        if(String(card.characters.suffix(2)) == "se") {
            wasReverse = true
            reverse = !reverse
        }
        if isDraw(card) {
            wasDraw = true
            if(userIndex != 0) {
                giveCards(card, target:chooseTarget(userIndex))
            } else {
                if(numberOfOpponents == 1) {
                    giveCards(card, target:0)
                }
            }
            DispatchQueue.main.async {
                    self.updateUserHand()
            }
            
        }
        if (firstLetter(card) == "W") {
            if(userIndex != 0) {
                let tempCard = Card()
                tempCard.type = randomColor()
                DispatchQueue.main.async {
                    self.playedCard.image = UIImage(named: tempCard.type)
                }
            }
        }
        if (lastLetter(card) == "p") {
            skipped = true
        }
        DispatchQueue.main.async {
                self.animateCard(self.enemyImages[userIndex-1].frame.origin, endPoint: self.playedCard.frame.origin, image: UIImage(named:choice.type)!)
        }
        
    }
    
    
    
    
    // Iterate through opponent turns
    func enemyTurn() {

        DispatchQueue.main.async {
            self.removeEdit(self.scroll)
        }
        
        
        while(!checkVictory() && currentPlayer != 0) {
            let currentHighlight = currentPlayer
            DispatchQueue.main.async {
                self.highlightOpponent()
            }
            doMove(currentPlayer)
            
            if(numberOfOpponents == 1) {
                if(skipped || wasDraw || wasReverse) {
                    skipped = false
                    wasDraw = false
                    wasReverse = false
                } else {
                    currentPlayer = 0
                }
            }
            
            else if(!reverse) {
                if(skipped) {
                    if (currentPlayer == numberOfOpponents-1) {
                        currentPlayer = 0
                    } else if (currentPlayer == numberOfOpponents) {
                        currentPlayer = 1
                    } else {
                        currentPlayer+=2
                    }
                    skipped = false
                } else {
                    if(currentPlayer == numberOfOpponents) {
                        currentPlayer = 0
                    } else {
                        currentPlayer+=1
                    }
                }
                
            } else {
        
                if(skipped) {
                    if(currentPlayer == 1) {
                        currentPlayer = numberOfOpponents
                    } else {
                        currentPlayer-=2
                    }
                    skipped = false
                } else {
                    currentPlayer-=1
                }
  
            }
            DispatchQueue.main.async {
                self.removeHighlight(currentHighlight)
            }
            print("Current Player is now \(currentPlayer)")
        }
        DispatchQueue.main.async {
            self.edit(self.scroll)
            if(self.checkVictory()) {
                self.victory()
            }
        }
        
    }
}

extension GameViewController: UITextFieldDelegate {
    //MARK: textfield delegate protocol

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let cardImage = UIImage(named: textField.text!) {
            
            // Add card to player array
            giveCard(players[0])
            let card = players[0].hand[players[0].hand.count-1]
            card.type = textField.text!
            // Setup for the button
            let cardButton = card.image
            setHandConstraints(cardButton)
            cardButton.adjustsImageWhenHighlighted = false
            
            xPos += buffer
            
            var endPoint = CGPoint(x: (view.frame.width - (buffer + iWidth)), y: cardButton.frame.origin.y + scroll.frame.origin.y)
            // change the endpoint of animation if there are only 1 or 2 cards left
            if(players[0].hand.count < 4) {
                endPoint = CGPoint(x: xPos, y: cardButton.frame.origin.y + scroll.frame.origin.y)
            }
            
            card.xVal = xPos
            cardButton.frame.origin.x = xPos
            print("\(card.type) is now in your hand")
            cardButton.titleLabel!.text = card.type
            xPos += (iWidth + buffer)
            cardButton.setImage(cardImage, for: UIControlState())
            
            scroll.contentSize.width = xPos
            if(xPos > self.view.frame.width) {
                let offset:CGPoint = CGPoint(x: (xPos - self.view.frame.width), y: 0)
                scroll.setContentOffset(offset, animated: true)
            }
            // Set the image to animate's origin and image
            imageToAnimate.frame.origin = drawCard.frame.origin
            imageToAnimate.image = UIImage(named: card.type)
            view.addSubview(imageToAnimate)
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.drawCard.isEnabled = false
                self.imageToAnimate.frame.origin = endPoint
                }, completion: { finished in
                    self.drawCard.isEnabled = true
                    self.scroll.addSubview(cardButton)
                    self.imageToAnimate.removeFromSuperview()
            }   )
        } else if textField.text! == "dismiss"{
            print("Dismissing view")
            dismiss(animated: true, completion: nil)
        }
        else {
            print("Could not find asset named \(textField.text!)")
        }
        return true
    }
    
    @IBAction func toggleTextField(_ sender:UIButton) {
        textField.isHidden ? (textField.isHidden = false) : (textField.isHidden = true)
    }
    
}



