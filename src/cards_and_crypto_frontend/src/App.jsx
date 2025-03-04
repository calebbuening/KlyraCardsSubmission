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
  const [betType, setBetType] = useState('color'); // color, suit, or value
  const [betValue, setBetValue] = useState('black'); // default to black
  const [isMobile, setIsMobile] = useState(window.innerWidth <= 600);

  // Available bet options based on bet type
  const betOptions = {
    color: ['red', 'black'],
    suit: ['hearts', 'diamonds', 'clubs', 'spades'],
    value: ['A', 'K', 'Q', 'J', '10', '9', '8', '7', '6', '5', '4', '3', '2']
  };

  // Check if viewport is mobile on resize
  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth <= 600);
    };

    window.addEventListener('resize', handleResize);
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  // Handle bet type change
  const handleBetTypeChange = (newType) => {
    setBetType(newType);
    // Reset bet value to first option of the new type
    setBetValue(betOptions[newType][0]);
  };

  // Play the game
  async function playGame() {
    if (betAmount <= 0) {
      toast.error('Bet amount must be greater than 0!');
      return;
    }

    try {
      setIsPlaying(true);
      setGameResult(null);
      
      // Prepare the bet object
      const bet = {
        betType: { [betType]: null }, // Using variant syntax for Motoko
        betValue: betValue
      };
      
      // Call the updated backend to play the game with the bet
      const result = await cards_and_crypto_backend.playGame(bet);
      
      // Update the UI with the result
      setGameResult(result);
      
      // Handle the bet result
      if (result.won) {
        // Player won - multiply bet by payout
        toast.success(`You won ${betAmount * result.payout} ETH!`, {
          position: isMobile ? "top-center" : "top-right"
        });
        // In a real app, we would transfer funds here
      } else {
        // Player lost - deduct the bet amount
        toast.error(`You lost ${betAmount} ETH!`, {
          position: isMobile ? "top-center" : "top-right"
        });
        // In a real app, we would transfer funds here
      }
      
    } catch (error) {
      toast.error(`Error playing game: ${error.message}`, {
        position: isMobile ? "top-center" : "top-right"
      });
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

  // Get payout multiplier based on bet type
  function getPayoutMultiplier() {
    switch (betType) {
      case 'color': return '2x';
      case 'suit': return '4x';
      case 'value': return '13x';
      default: return '';
    }
  }

  return (
    <main className="app-container">
      <ToastContainer position={isMobile ? "top-center" : "top-right"} autoClose={5000} />
      
      <h1 style={{ fontFamily: 'Comic Sans MS, cursive' }}>DOGE CASIO</h1>
      <p className="description">
        Place a bet on color, suit, or value and draw a card.<br />
        Win based on your bet: Color (2x), Suit (4x), Value (13x)
      </p>
      
      <div className="game-section">
        {/* Card display is shown first on mobile for better UX */}
        {isMobile && (
          <div className="card-display">
            {isPlaying ? (
              <div className="loading-card">Drawing...</div>
            ) : gameResult ? (
              <>
                {getCardImage(gameResult.card)}
                <div className="result-info">
                  {gameResult.won ? (
                    <div className="won">You won {betAmount * gameResult.payout} ETH!</div>
                  ) : (
                    <div className="lost">You lost {betAmount} ETH!</div>
                  )}
                </div>
              </>
            ) : (
              <div className="card card-back">
                <div className="card-back-design"></div>
              </div>
            )}
          </div>
        )}

        <div className="bet-controls">
          <div className="bet-type-selection">
            <label>Bet Type:</label>
            <div className="bet-type-buttons">
              <button 
                className={betType === 'color' ? 'active' : ''} 
                onClick={() => handleBetTypeChange('color')}
                disabled={isPlaying}
              >
                Color (2x)
              </button>
              <button 
                className={betType === 'suit' ? 'active' : ''} 
                onClick={() => handleBetTypeChange('suit')}
                disabled={isPlaying}
              >
                Suit (4x)
              </button>
              <button 
                className={betType === 'value' ? 'active' : ''} 
                onClick={() => handleBetTypeChange('value')}
                disabled={isPlaying}
              >
                Value (13x)
              </button>
            </div>
          </div>
          
          <div className="bet-value-selection">
            <label>Betting on:</label>
            <select 
              value={betValue} 
              onChange={(e) => setBetValue(e.target.value)}
              disabled={isPlaying}
            >
              {betOptions[betType].map(option => (
                <option key={option} value={option}>
                  {option}
                </option>
              ))}
            </select>
          </div>
          
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
        
        {/* Card display is shown last on desktop */}
        {!isMobile && (
          <div className="card-display">
            {isPlaying ? (
              <div className="loading-card">Drawing...</div>
            ) : gameResult ? (
              <>
                {getCardImage(gameResult.card)}
                <div className="result-info">
                  {gameResult.won ? (
                    <div className="won">You won {betAmount * gameResult.payout} ETH!</div>
                  ) : (
                    <div className="lost">You lost {betAmount} ETH!</div>
                  )}
                </div>
              </>
            ) : (
              <div className="card card-back">
                <div className="card-back-design"></div>
              </div>
            )}
          </div>
        )}
      </div>
    </main>
  );
}

export default App;
