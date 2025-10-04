import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>⚽ SambaIQ</Text>
      <Text style={styles.subtitle}>Duolingo för Fotboll</Text>
      
      <TouchableOpacity style={styles.button}>
        <Text style={styles.buttonText}>🚀 Starta Träning</Text>
      </TouchableOpacity>
      
      <Text style={styles.description}>
        Lär dig fotbollstaktik på 5 minuter om dagen!
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#2E8B57',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 48,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 24,
    color: 'rgba(255,255,255,0.9)',
    marginBottom: 40,
  },
  button: {
    backgroundColor: '#FFD700',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 25,
    marginBottom: 30,
  },
  buttonText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2E8B57',
  },
  description: {
    fontSize: 16,
    color: 'rgba(255,255,255,0.8)',
    textAlign: 'center',
    lineHeight: 24,
  },
});