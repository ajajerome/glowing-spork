import React from 'react';
import { View, Dimensions } from 'react-native';
import Svg, { 
  Rect, 
  Circle, 
  Line, 
  Path, 
  Defs, 
  LinearGradient as SvgLinearGradient,
  Stop,
  G
} from 'react-native-svg';

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

// FC-inspired football pitch component
// Foundation-first: Classic, recognizable design that everyone knows
const FCFootballPitch = ({ 
  pitchSize = '11v11', // '7v7', '9v9', '11v11' 
  children,
  style 
}) => {
  
  // Pitch dimensions based on age group (FC-style proportions)
  const getPitchDimensions = () => {
    const baseWidth = screenWidth - 40;
    const aspectRatio = pitchSize === '7v7' ? 1.3 : pitchSize === '9v9' ? 1.4 : 1.5;
    
    return {
      width: baseWidth,
      height: baseWidth / aspectRatio,
      margin: 20
    };
  };

  const { width, height, margin } = getPitchDimensions();
  
  // FC-inspired colors
  const colors = {
    grass: '#2E8B57',        // Classic football green
    grassDark: '#228B22',    // Darker green for depth
    lines: '#FFFFFF',        // Pure white lines
    penalty: '#32CD32',      // Slightly lighter green for penalty area
    center: '#90EE90'        // Light green for center circle
  };

  // Pitch proportions (FC-style)
  const proportions = {
    penaltyAreaWidth: width * 0.35,
    penaltyAreaHeight: height * 0.25,
    goalAreaWidth: width * 0.15,
    goalAreaHeight: height * 0.12,
    centerCircleRadius: Math.min(width, height) * 0.12,
    goalWidth: width * 0.12,
    goalHeight: height * 0.08,
    lineWidth: 2
  };

  return (
    <View style={[styles.container, style]}>
      <Svg
        width={width}
        height={height}
        viewBox={`0 0 ${width} ${height}`}
      >
        {/* Gradient definitions for FC-style depth */}
        <Defs>
          <SvgLinearGradient id="grassGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <Stop offset="0%" stopColor={colors.grass} />
            <Stop offset="50%" stopColor={colors.grassDark} />
            <Stop offset="100%" stopColor={colors.grass} />
          </SvgLinearGradient>
        </Defs>

        {/* Main pitch background (FC-style grass) */}
        <Rect
          x="0"
          y="0"
          width={width}
          height={height}
          fill="url(#grassGradient)"
          rx="8"
        />

        {/* Pitch outline */}
        <Rect
          x={proportions.lineWidth}
          y={proportions.lineWidth}
          width={width - proportions.lineWidth * 2}
          height={height - proportions.lineWidth * 2}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
          rx="4"
        />

        {/* Center line */}
        <Line
          x1={width / 2}
          y1={proportions.lineWidth}
          x2={width / 2}
          y2={height - proportions.lineWidth}
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />

        {/* Center circle (FC-style) */}
        <Circle
          cx={width / 2}
          cy={height / 2}
          r={proportions.centerCircleRadius}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />

        {/* Center spot */}
        <Circle
          cx={width / 2}
          cy={height / 2}
          r="3"
          fill={colors.lines}
        />

        {/* Top penalty area */}
        <Rect
          x={(width - proportions.penaltyAreaWidth) / 2}
          y={proportions.lineWidth}
          width={proportions.penaltyAreaWidth}
          height={proportions.penaltyAreaHeight}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />

        {/* Top goal area */}
        <Rect
          x={(width - proportions.goalAreaWidth) / 2}
          y={proportions.lineWidth}
          width={proportions.goalAreaWidth}
          height={proportions.goalAreaHeight}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />

        {/* Top goal */}
        <Rect
          x={(width - proportions.goalWidth) / 2}
          y="0"
          width={proportions.goalWidth}
          height={proportions.goalHeight}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth * 1.5}
        />

        {/* Bottom penalty area */}
        <Rect
          x={(width - proportions.penaltyAreaWidth) / 2}
          y={height - proportions.penaltyAreaHeight - proportions.lineWidth}
          width={proportions.penaltyAreaWidth}
          height={proportions.penaltyAreaHeight}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />

        {/* Bottom goal area */}
        <Rect
          x={(width - proportions.goalAreaWidth) / 2}
          y={height - proportions.goalAreaHeight - proportions.lineWidth}
          width={proportions.goalAreaWidth}
          height={proportions.goalAreaHeight}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />

        {/* Bottom goal */}
        <Rect
          x={(width - proportions.goalWidth) / 2}
          y={height - proportions.goalHeight}
          width={proportions.goalWidth}
          height={proportions.goalHeight}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth * 1.5}
        />

        {/* Penalty spots */}
        <Circle
          cx={width / 2}
          cy={proportions.penaltyAreaHeight * 0.6}
          r="2"
          fill={colors.lines}
        />
        <Circle
          cx={width / 2}
          cy={height - proportions.penaltyAreaHeight * 0.6}
          r="2"
          fill={colors.lines}
        />

        {/* Corner arcs (FC-style) */}
        <Path
          d={`M ${proportions.lineWidth} ${proportions.lineWidth + 15} 
              A 15 15 0 0 1 ${proportions.lineWidth + 15} ${proportions.lineWidth}`}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />
        <Path
          d={`M ${width - proportions.lineWidth - 15} ${proportions.lineWidth} 
              A 15 15 0 0 1 ${width - proportions.lineWidth} ${proportions.lineWidth + 15}`}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />
        <Path
          d={`M ${width - proportions.lineWidth} ${height - proportions.lineWidth - 15} 
              A 15 15 0 0 1 ${width - proportions.lineWidth - 15} ${height - proportions.lineWidth}`}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />
        <Path
          d={`M ${proportions.lineWidth + 15} ${height - proportions.lineWidth} 
              A 15 15 0 0 1 ${proportions.lineWidth} ${height - proportions.lineWidth - 15}`}
          fill="none"
          stroke={colors.lines}
          strokeWidth={proportions.lineWidth}
        />

        {/* Children components (players, ball, etc.) */}
        {children}
      </Svg>
    </View>
  );
};

const styles = {
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  }
};

export default FCFootballPitch;