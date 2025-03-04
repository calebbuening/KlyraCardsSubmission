// Import the required libraries
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Random "mo:base/Random";

actor {
  // Game state
  private stable var seed : Nat = 0;
  
  // Card types
  type Card = {
    color : Text; // "red" or "black"
    suit : Text;  // "hearts", "diamonds", "clubs", "spades"
    value : Text; // "2" through "10", "J", "Q", "K", "A"
  };
  
  // Draw a random card
  public func drawCard() : async Card {
    // Update seed for randomness
    seed := seed + 1 + Int.abs(Time.now());
    
    // Create pseudo-random values
    let random_suit = seed % 4;
    let random_value = (seed / 4) % 13;
    
    // Determine suit and color
    let suit = switch (random_suit) {
      case 0 { "hearts" };
      case 1 { "diamonds" };
      case 2 { "clubs" };
      case _ { "spades" };
    };
    
    let color = switch (suit) {
      case "hearts" { "red" };
      case "diamonds" { "red" };
      case _ { "black" };
    };
    
    // Determine card value
    let value = switch (random_value) {
      case 0 { "2" };
      case 1 { "3" };
      case 2 { "4" };
      case 3 { "5" };
      case 4 { "6" };
      case 5 { "7" };
      case 6 { "8" };
      case 7 { "9" };
      case 8 { "10" };
      case 9 { "J" };
      case 10 { "Q" };
      case 11 { "K" };
      case _ { "A" };
    };
    
    return {
      color;
      suit;
      value;
    };
  };
  
  // Play the game
  public func playGame() : async {
    won : Bool;
    card : Card;
  } {
    let card = await drawCard();
    let won = card.color == "black";
    
    return {
      won;
      card;
    };
  };
};
