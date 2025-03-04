import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { cards_and_crypto_backend } from 'declarations/cards_and_crypto_backend';
import './App.css';

function App() {
  // States
  const [betAmount, setBetAmount] = useState(0.01);
  const [isPlaying, setIsPlaying] = useState(false);
  const [gameResult, setGameResult] = useState(null);

  // Play the game
  async function playGame() {
    if (betAmount <= 0) {
      toast.error('Bet amount must be greater than 0!');
      return;
    }

    try {
      setIsPlaying(true);
      setGameResult(null);
      
      // Call the backend to play the game
      const result = await cards_and_crypto_backend.playGame();
      
      // Update the UI with the result
      setGameResult(result);
      
      // Handle the bet
      if (result.won) {
        // Player won - double the bet amount
        toast.success(`You won ${betAmount * 2} ETH!`);
        // In a real app, we would transfer funds here
      } else {
        // Player lost - deduct the bet amount
        toast.error(`You lost ${betAmount} ETH!`);
        // In a real app, we would transfer funds here
      }
      
    } catch (error) {
      toast.error(`Error playing game: ${error.message}`);
      console.error(error);
    } finally {
      setIsPlaying(false);
    }
  }

  // Get card image based on suit and value
  function getCardImage(card) {
    if (!card) return null;
    return (
      <div className={`card ${card.color}`}>
        <div className="card-value">{card.value}</div>
        <div className="card-suit">{getSuitSymbol(card.suit)}</div>
      </div>
    );
  }
  
  // Get suit symbol
  function getSuitSymbol(suit) {
    switch (suit) {
      case 'hearts': return '♥';
      case 'diamonds': return '♦';
      case 'clubs': return '♣';
      case 'spades': return '♠';
      default: return '';
    }
  }

  return (
    <main className="app-container">
      <ToastContainer position="top-right" autoClose={5000} />
      
      <h1 style={{ fontFamily: 'Comic Sans MS, cursive' }}>DOGE CASIO</h1>
      <p className="description">
        Place a bet and draw a card.<br />
        Black card = double your money, Red card = lose your bet.
      </p>
      
      <div className="game-section">
        <div className="bet-controls">
          <label htmlFor="bet-amount">Bet Amount (ETH):</label>
          <input
            id="bet-amount"
            type="number"
            min="0.001"
            step="0.001"
            value={betAmount}
            onChange={(e) => setBetAmount(parseFloat(e.target.value))}
            disabled={isPlaying}
          />
          <button 
            className="play-button" 
            onClick={playGame} 
            disabled={isPlaying}
          >
            {isPlaying ? 'Drawing Card...' : 'Draw Card'}
          </button>
        </div>
        
        <div className="card-display">
          {isPlaying ? (
            <div className="loading-card">Drawing...</div>
          ) : gameResult ? (
            <>
              {getCardImage(gameResult.card)}
              <div className={`result ${gameResult.won ? 'win' : 'lose'}`}>
                {gameResult.won ? `WIN! (${betAmount * 2} ETH)` : `LOSE! (${betAmount} ETH)`}
              </div>
            </>
          ) : (
            <div className="card card-back">
              <div className="card-back-design"></div>
            </div>
          )}
        </div>
      </div>
    </main>
  );
}

export default App;
