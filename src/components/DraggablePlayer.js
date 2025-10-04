import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Svg, { Circle, Text as SvgText } from 'react-native-svg';

// FC-inspired draggable player component
// Foundation-first: Simple, recognizable design like FC series
const DraggablePlayer = ({ 
  position, 
  color = '#4444FF', 
  number = '7', 
  size = 25,
  draggable = false,
  isUser = false 
}) => {
  
  // FC-style player colors
  const getPlayerStyle = () => {
    if (isUser) {
      return {
        fill: '#FFD700',        // Gold for user player
        stroke: '#FF6B35',      // Orange outline
        strokeWidth: 3
      };
    } else if (color === '#FF4444') {
      return {
        fill: '#FF4444',        // Red for opponents
        stroke: '#CC0000',      // Darker red outline
        strokeWidth: 2
      };
    } else {
      return {
        fill: '#4444FF',        // Blue for teammates
        stroke: '#0000CC',      // Darker blue outline  
        strokeWidth: 2
      };
    }
  };

  const playerStyle = getPlayerStyle();

  return (
    <View
      style={[
        styles.playerContainer,
        {
          left: position.x - size/2,
          top: position.y - size/2,
          width: size,
          height: size,
        },
        isUser && styles.userPlayer,
        draggable && styles.draggable
      ]}
    >
      <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        {/* Player circle (FC-style) */}
        <Circle
          cx={size/2}
          cy={size/2}
          r={size/2 - 2}
          fill={playerStyle.fill}
          stroke={playerStyle.stroke}
          strokeWidth={playerStyle.strokeWidth}
        />
        
        {/* Player number */}
        <SvgText
          x={size/2}
          y={size/2 + 4}
          fontSize={size * 0.4}
          fontWeight="bold"
          fill="white"
          textAnchor="middle"
        >
          {number}
        </SvgText>
      </Svg>
      
      {/* User player indicator */}
      {isUser && (
        <View style={styles.userIndicator}>
          <Text style={styles.userIndicatorText}>DU</Text>
        </View>
      )}
      
      {/* Draggable hint */}
      {draggable && !isUser && (
        <View style={styles.dragHint}>
          <Text style={styles.dragHintText}>↕️</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  playerContainer: {
    position: 'absolute',
    justifyContent: 'center',
    alignItems: 'center',
  },
  userPlayer: {
    // Special styling for user's player
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 8,
    elevation: 8,
  },
  draggable: {
    // Visual hint that this player can be moved
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.5)',
    borderRadius: 50,
    borderStyle: 'dashed',
  },
  userIndicator: {
    position: 'absolute',
    top: -15,
    backgroundColor: '#FFD700',
    borderRadius: 8,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  userIndicatorText: {
    color: '#2E8B57',
    fontSize: 10,
    fontWeight: 'bold',
  },
  dragHint: {
    position: 'absolute',
    bottom: -15,
    backgroundColor: 'rgba(255,255,255,0.8)',
    borderRadius: 10,
    paddingHorizontal: 4,
    paddingVertical: 2,
  },
  dragHintText: {
    fontSize: 12,
  },
});

export default DraggablePlayer;