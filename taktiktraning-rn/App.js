import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Dimensions, StatusBar } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Components
import OnboardingScreen from './src/screens/OnboardingScreen';
import DailyLessonScreen from './src/screens/DailyLessonScreen';
import ProgressScreen from './src/screens/ProgressScreen';

// Foundation-first: Simple app structure for MVP
export default function App() {
  const [currentScreen, setCurrentScreen] = useState('loading');
  const [userProfile, setUserProfile] = useState(null);

  useEffect(() => {
    checkUserProfile();
  }, []);

  const checkUserProfile = async () => {
    try {
      const profile = await AsyncStorage.getItem('userProfile');
      if (profile) {
        setUserProfile(JSON.parse(profile));
        setCurrentScreen('lesson');
      } else {
        setCurrentScreen('onboarding');
      }
    } catch (error) {
      console.log('Error loading user profile:', error);
      setCurrentScreen('onboarding');
    }
  };

  const handleOnboardingComplete = async (profile) => {
    try {
      await AsyncStorage.setItem('userProfile', JSON.stringify(profile));
      setUserProfile(profile);
      setCurrentScreen('lesson');
    } catch (error) {
      console.log('Error saving user profile:', error);
    }
  };

  const renderScreen = () => {
    switch (currentScreen) {
      case 'loading':
        return <LoadingScreen />;
      case 'onboarding':
        return (
          <OnboardingScreen 
            onComplete={handleOnboardingComplete}
          />
        );
      case 'lesson':
        return (
          <DailyLessonScreen 
            userProfile={userProfile}
            onNavigate={setCurrentScreen}
          />
        );
      case 'progress':
        return (
          <ProgressScreen 
            userProfile={userProfile}
            onNavigate={setCurrentScreen}
          />
        );
      default:
        return <LoadingScreen />;
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#2E8B57" />
      {renderScreen()}
    </View>
  );
}

// Loading screen component
const LoadingScreen = () => (
  <LinearGradient
    colors={['#2E8B57', '#228B22']}
    style={styles.container}
  >
    <View style={styles.loadingContainer}>
      <Text style={styles.loadingTitle}>⚽</Text>
      <Text style={styles.loadingText}>SambaIQ</Text>
      <Text style={styles.loadingSubtext}>Duolingo för Fotboll</Text>
    </View>
  </LinearGradient>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  loadingTitle: {
    fontSize: 80,
    marginBottom: 20,
  },
  loadingText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 10,
    textAlign: 'center',
  },
  loadingSubtext: {
    fontSize: 18,
    color: 'rgba(255,255,255,0.8)',
    textAlign: 'center',
  },
});