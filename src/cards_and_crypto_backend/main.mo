// Import the required libraries
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Random "mo:base/Random";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Error "mo:base/Error";

actor {
  // Game state
  private stable var seed : Nat = 0;
  private stable var lastCardResult : ?Text = null;
  
  // Card types
  public type Card = {
    color : Text; // "red" or "black"
    suit : Text;  // "hearts", "diamonds", "clubs", "spades"
    value : Text; // "2" through "10", "J", "Q", "K", "A"
  };

  // Fallback deck in case the API call fails
  private let fallbackDeck : [Card] = [
    // Hearts (red)
    { color = "red"; suit = "hearts"; value = "A" },
    { color = "red"; suit = "hearts"; value = "K" },
    { color = "red"; suit = "hearts"; value = "Q" },
    { color = "red"; suit = "hearts"; value = "J" },
    { color = "red"; suit = "hearts"; value = "10" },
    { color = "red"; suit = "hearts"; value = "9" },
    { color = "red"; suit = "hearts"; value = "8" },
    { color = "red"; suit = "hearts"; value = "7" },
    { color = "red"; suit = "hearts"; value = "6" },
    { color = "red"; suit = "hearts"; value = "5" },
    { color = "red"; suit = "hearts"; value = "4" },
    { color = "red"; suit = "hearts"; value = "3" },
    { color = "red"; suit = "hearts"; value = "2" },
    
    // Diamonds (red)
    { color = "red"; suit = "diamonds"; value = "A" },
    { color = "red"; suit = "diamonds"; value = "K" },
    { color = "red"; suit = "diamonds"; value = "Q" },
    { color = "red"; suit = "diamonds"; value = "J" },
    { color = "red"; suit = "diamonds"; value = "10" },
    { color = "red"; suit = "diamonds"; value = "9" },
    { color = "red"; suit = "diamonds"; value = "8" },
    { color = "red"; suit = "diamonds"; value = "7" },
    { color = "red"; suit = "diamonds"; value = "6" },
    { color = "red"; suit = "diamonds"; value = "5" },
    { color = "red"; suit = "diamonds"; value = "4" },
    { color = "red"; suit = "diamonds"; value = "3" },
    { color = "red"; suit = "diamonds"; value = "2" },
    
    // Clubs (black)
    { color = "black"; suit = "clubs"; value = "A" },
    { color = "black"; suit = "clubs"; value = "K" },
    { color = "black"; suit = "clubs"; value = "Q" },
    { color = "black"; suit = "clubs"; value = "J" },
    { color = "black"; suit = "clubs"; value = "10" },
    { color = "black"; suit = "clubs"; value = "9" },
    { color = "black"; suit = "clubs"; value = "8" },
    { color = "black"; suit = "clubs"; value = "7" },
    { color = "black"; suit = "clubs"; value = "6" },
    { color = "black"; suit = "clubs"; value = "5" },
    { color = "black"; suit = "clubs"; value = "4" },
    { color = "black"; suit = "clubs"; value = "3" },
    { color = "black"; suit = "clubs"; value = "2" },
    
    // Spades (black)
    { color = "black"; suit = "spades"; value = "A" },
    { color = "black"; suit = "spades"; value = "K" },
    { color = "black"; suit = "spades"; value = "Q" },
    { color = "black"; suit = "spades"; value = "J" },
    { color = "black"; suit = "spades"; value = "10" },
    { color = "black"; suit = "spades"; value = "9" },
    { color = "black"; suit = "spades"; value = "8" },
    { color = "black"; suit = "spades"; value = "7" },
    { color = "black"; suit = "spades"; value = "6" },
    { color = "black"; suit = "spades"; value = "5" },
    { color = "black"; suit = "spades"; value = "4" },
    { color = "black"; suit = "spades"; value = "3" },
    { color = "black"; suit = "spades"; value = "2" }
  ];
  
  // Management canister types for HTTP requests
  public type HttpRequestArgs = {
    url : Text;
    max_response_bytes : ?Nat64;
    headers : [HttpHeader];
    body : ?[Nat8];
    method : HttpMethod;
    transform : ?TransformContext;
  };

  public type HttpHeader = {
    name : Text;
    value : Text;
  };

  public type HttpMethod = {
    #get;
    #post;
    #head;
  };

  public type HttpResponsePayload = {
    status : Nat;
    headers : [HttpHeader];
    body : [Nat8];
  };

  public type TransformContext = {
    function : shared TransformArgs -> async HttpResponsePayload;
    context : Blob;
  };

  public type TransformArgs = {
    response : HttpResponsePayload;
    context : Blob;
  };

  // The IC management canister
  let ic : actor {
    http_request : HttpRequestArgs -> async HttpResponsePayload;
  } = actor("aaaaa-aa");

  // QRandom API endpoint
  private let QRANDOM_URL = "https://qrandom.io/api/random/deck?cards=1";
  
  // Simple test function to check if canister calls are working
  public func test() : async Text {
    return "Hello, World!";
  };
  
  // Get a hardcoded card for testing
  public func getTestCard() : async Card {
    return {
      color = "black";
      suit = "spades";
      value = "A";
    };
  };
  
  // For debugging: get the last raw API response
  public func getLastCardResult() : async Text {
    switch (lastCardResult) {
      case (null) { return "No card has been drawn yet"; };
      case (?text) { return text; };
    };
  };
  
  // Get a card from qrandom API
  public func fetchRandomCard() : async Card {
    try {
      // Make the HTTP request to qrandom API
      let requestHeaders = [
        { name = "Accept"; value = "application/json" }
      ];
      
      let request_args : HttpRequestArgs = {
        url = QRANDOM_URL;
        max_response_bytes = ?10000;
        headers = requestHeaders;
        body = null;
        method = #get;
        transform = null;
      };
      
      // Call the qrandom API
      let response = await ic.http_request(request_args);
      
      // Convert response body to text
      let response_body_bytes = response.body;
      let response_body_text = Text.decodeUtf8(Blob.fromArray(response_body_bytes));
      
      // Store the response for debugging
      switch (response_body_text) {
        case (?text) { lastCardResult := ?text; };
        case (null) { lastCardResult := ?"Error decoding response"; };
      };
      
      // Debug print the response
      let responseText = switch (response_body_text) {
        case (?text) { text };
        case (null) { "Error decoding response" };
      };
      
      Debug.print("QRandom API Response: " # responseText);
      
      // Parse the response
      let suit = if (Text.contains(responseText, #text("hearts"))) { "hearts" }
                 else if (Text.contains(responseText, #text("diamonds"))) { "diamonds" }
                 else if (Text.contains(responseText, #text("clubs"))) { "clubs" }
                 else { "spades" };
                 
      let rank = if (Text.contains(responseText, #text("\"ace\""))) { "A" }
                 else if (Text.contains(responseText, #text("\"king\""))) { "K" }
                 else if (Text.contains(responseText, #text("\"queen\""))) { "Q" }
                 else if (Text.contains(responseText, #text("\"jack\""))) { "J" }
                 else if (Text.contains(responseText, #text("\"10\""))) { "10" }
                 else if (Text.contains(responseText, #text("\"9\""))) { "9" }
                 else if (Text.contains(responseText, #text("\"8\""))) { "8" }
                 else if (Text.contains(responseText, #text("\"7\""))) { "7" }
                 else if (Text.contains(responseText, #text("\"6\""))) { "6" }
                 else if (Text.contains(responseText, #text("\"5\""))) { "5" }
                 else if (Text.contains(responseText, #text("\"4\""))) { "4" }
                 else if (Text.contains(responseText, #text("\"3\""))) { "3" }
                 else { "2" };
      
      let color = if (suit == "hearts" or suit == "diamonds") { "red" } else { "black" };
      
      // Debug print the parsed card
      Debug.print("Parsed Card: Suit: " # suit # ", Rank: " # rank # ", Color: " # color);
      
      return {
        color;
        suit;
        value = rank;
      };
    } catch (error) {
      // If the API call fails, use a fallback random card
      Debug.print("Error calling QRandom API: " # Error.message(error));
      
      // Use time-based random as fallback
      seed := seed + 1 + Int.abs(Time.now());
      let index = seed % fallbackDeck.size();
      
      return fallbackDeck[index];
    };
  };
  
  // Draw a fallback random card if API fails
  private func drawFallbackRandomCard() : Card {
    // Update seed for randomness
    seed := seed + 1 + Int.abs(Time.now());
    
    // Get a random index into the deck
    let index = seed % fallbackDeck.size();
    
    // Return the card at that index
    fallbackDeck[index];
  };
  
  // Play the game
  public func playGame() : async {
    won : Bool;
    card : Card;
  } {
    // Get a random card from the QRandom API
    let card = await fetchRandomCard();
    let won = card.color == "black";
    
    // Debug: Print the game result
    Debug.print("Game Result: " # (if won { "WON" } else { "LOST" }));
    Debug.print("Card: " # card.color # " " # card.suit # " " # card.value);
    
    return {
      won;
      card;
    };
  };
};
