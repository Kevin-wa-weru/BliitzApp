// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:bliitz/Features/Notifications/notifications.dart';
import 'package:bliitz/services/sql_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class Misc {
  List<Map<String, dynamic>> getCategoryItems();
  List<Map<String, dynamic>> getSocialNames();
  List<Map<String, dynamic>> getDummyGroups();
  List<Map<String, dynamic>> getDummyGroupsTwo();
  List<Map<String, dynamic>> getDummyNotifications();
  List<String> getAccountList();
  bool isValidEmail(String email);
  String? validatePassword(String? value);
  Future<bool> requestGalleryAndCameraPermission();
  bool isValidUrl(String url);
  Future<void> openLink(String url);

  Future<List<String>> getFavoriteLinks();
  Future<void> addFavorite(String linkId);
  Future<bool> isFavorite(String linkId);
  Future<void> removeFavorite(String linkId);

  Future<List<String>> getLikedLinks();
  Future<void> addLikedLinks(String linkId);
  Future<bool> isLikedLink(String linkId);
  Future<void> removeLikedLink(String linkId);

  Future<List<String>> getDisLikedLinks();
  Future<void> addDisLikedLinks(String linkId);
  Future<bool> isDisLikedLink(String linkId);
  Future<void> removeDisLikedLink(String linkId);

  Future<void> saveRecentSearches({
    required Map<String, dynamic> groupDetails,
  });
  Future<List<Map<String, dynamic>>> fetchSearchedLinks();

  Future<void> saveSearchSuggestions({
    required Map<String, dynamic> groupDetails,
  });
  Future<List<Map<String, dynamic>>> fetchSearchSuggestions();
  void deletedSearchSuggestion();

  persistCategoryCountsLocally();
  Future<List<Map<String, dynamic>>> fetchLocalCategoryCounts();

  Future<void> initiateForegroundNotifications(BuildContext context);
  Future<void> handleTerminatedNotificationTap(BuildContext context);
  Future<void> trackLinkImpression(
      {required String linkId, required String linkCreatorId});
  String resolvePlanTitle({required String planId});
}

class MiscImpl implements Misc {
  static const _favoritesKey = 'favorite_links';
  static const _likedKey = 'liked_links';
  static const _dislikedKey = 'disliked_links';
  @override
  List<Map<String, dynamic>> getDummyGroups() {
    return [
      {
        'name': 'Forex traders',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6RjDa1u9ezwN12QFfACkuaSDVCzR0c5BWOQ&s',
        'description':
            'A group for discussing forex trading strategies and tips.'
      },
      {
        'name': 'High School Memories',
        'imageUrl':
            'https://cloudinary.hbs.edu/hbsit/image/upload/s--Fm3oHP0m--/f_auto,c_fill,h_375,w_750,/v20200101/79015AB87FD6D3284472876E1ACC3428.jpg',
        'description': 'Revisit the good old high school days with friends.'
      },
      {
        'name': 'Music Lovers',
        'imageUrl':
            'https://i.pinimg.com/736x/c7/e4/b1/c7e4b153c32bf9b6eba97dce0b01f2b7.jpg',
        'description': 'A place for sharing and discovering great music.'
      },
      {
        'name': 'Gaming Professionals',
        'imageUrl':
            'https://i.ytimg.com/vi/EA0YC9m6D4s/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCPEDlv0VGPIr2CC_juaUkgVRDJDQ',
        'description':
            'Discuss the latest trends and tips in professional gaming.'
      },
      {
        'name': 'Football Fanatics',
        'imageUrl':
            'https://thesun.my/binrepository/2_3339706_20230728112908.jpg',
        'description': 'For those who live and breathe football.'
      },
      {
        'name': 'Movies and Series to Watch',
        'imageUrl':
            'https://www.pta.co.uk/pta/media/693-13-PTA_AUT22_Comedy-night.jpg',
        'description': 'Share and explore must-watch movies and series.'
      },
      {
        'name': 'Finance and Politics',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhq-RwOINUdWrp3jVGz3S9zb6pehan9kOBtg&s',
        'description': 'Stay updated on financial trends and political news.'
      },
      {
        'name': 'AI is the Future, the Future is Here',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7VLr3gZSqlfnybmCa1MXiBacZWB_qbIkJCg&s',
        'description': 'Discuss advancements and innovations in AI technology.'
      },
      {
        'name': 'Education is Key but to Where',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvABdDOpcooFFpqADJvIOx4LXyVEqXekCTWA&s',
        'description':
            'Explore the role and future of education in modern society.'
      },
      {
        'name': 'Art',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQiN6wj1RZGPXrRmSGmc3y4lCRDE9o3iaNJnQ&s',
        'description': 'Celebrate creativity and share your artistic endeavors.'
      },
      {
        'name': 'Health Tips and Nutrition',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3Rh9HC9FtYJCzzjfUL_u4g6yBSnp38U7Fog&s',
        'description': 'Learn and share tips for a healthier lifestyle.'
      },
      {
        'name': 'Fashion Trends',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOCdAu2-R6Huawx5SJxvB55iZHY6FLqpjSDw&s',
        'description': 'Stay updated with the latest in fashion.'
      },
      {
        'name': 'Tesla Fanatics',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdhkxRq140Y9d_s2UEJrwO4O1BheC6UWIzfg&s',
        'description':
            'A group for Tesla enthusiasts and electric vehicle fans.'
      },
      {
        'name': 'Project 2025',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpr-OizYZSkpCqcI1SwB0-61b4QM4MYfrs6w&s',
        'description': 'Collaborate and share ideas for the future.'
      },
      {
        'name': 'Investments and Futures',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJGPy-TIzdFCL6-dtBkDWqwewiwEavZO4bqQ&s',
        'description': 'Discuss investment opportunities and market trends.'
      },
      {
        'name': 'Books to Read',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'Share and discover books worth reading.'
      },
      {
        'name': 'Game Cheatcodes',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'Swap and share cheat codes for your favorite games.'
      },
      {
        'name': 'Kenya Spots to Visit',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'Discover must-visit locations across Kenya.'
      },
      {
        'name': 'Computer Programming',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'For those passionate about coding and development.'
      },
      {
        'name': 'Driverless Cars',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'Discuss the future of autonomous vehicles.'
      },
    ];
  }

  @override
  List<Map<String, dynamic>> getDummyGroupsTwo() {
    return [
      {
        'name': 'Currency Gurus',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6RjDa1u9ezwN12QFfACkuaSDVCzR0c5BWOQ&s',
        'description':
            'A group for discussing forex trading strategies and tips.'
      },
      {
        'name': 'Blast from High School',
        'imageUrl':
            'https://cloudinary.hbs.edu/hbsit/image/upload/s--Fm3oHP0m--/f_auto,c_fill,h_375,w_750,/v20200101/79015AB87FD6D3284472876E1ACC3428.jpg',
        'description': 'Revisit the good old high school days with friends.'
      },
      {
        'name': 'Rhythm Nation',
        'imageUrl':
            'https://i.pinimg.com/736x/c7/e4/b1/c7e4b153c32bf9b6eba97dce0b01f2b7.jpg',
        'description': 'A place for sharing and discovering great music.'
      },
      {
        'name': 'Pro Gamers Hub',
        'imageUrl':
            'https://i.ytimg.com/vi/EA0YC9m6D4s/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCPEDlv0VGPIr2CC_juaUkgVRDJDQ',
        'description':
            'Discuss the latest trends and tips in professional gaming.'
      },
      {
        'name': 'The Football Arena',
        'imageUrl':
            'https://thesun.my/binrepository/2_3339706_20230728112908.jpg',
        'description': 'For those who live and breathe football.'
      },
      {
        'name': 'Binge-Worthy Picks',
        'imageUrl':
            'https://www.pta.co.uk/pta/media/693-13-PTA_AUT22_Comedy-night.jpg',
        'description': 'Share and explore must-watch movies and series.'
      },
      {
        'name': 'Money Talks & Policy',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhq-RwOINUdWrp3jVGz3S9zb6pehan9kOBtg&s',
        'description': 'Stay updated on financial trends and political news.'
      },
      {
        'name': 'AI Revolutionaries',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7VLr3gZSqlfnybmCa1MXiBacZWB_qbIkJCg&s',
        'description': 'Discuss advancements and innovations in AI technology.'
      },
      {
        'name': 'The Education Debate',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvABdDOpcooFFpqADJvIOx4LXyVEqXekCTWA&s',
        'description':
            'Explore the role and future of education in modern society.'
      },
      {
        'name': 'Canvas of Creativity',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQiN6wj1RZGPXrRmSGmc3y4lCRDE9o3iaNJnQ&s',
        'description': 'Celebrate creativity and share your artistic endeavors.'
      },
      {
        'name': 'Healthy Living Forum',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3Rh9HC9FtYJCzzjfUL_u4g6yBSnp38U7Fog&s',
        'description': 'Learn and share tips for a healthier lifestyle.'
      },
      {
        'name': 'Runway Trends',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOCdAu2-R6Huawx5SJxvB55iZHY6FLqpjSDw&s',
        'description': 'Stay updated with the latest in fashion.'
      },
      {
        'name': 'Electric Revolutionaries',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdhkxRq140Y9d_s2UEJrwO4O1BheC6UWIzfg&s',
        'description':
            'A group for Tesla enthusiasts and electric vehicle fans.'
      },
      {
        'name': 'Vision 2025',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpr-OizYZSkpCqcI1SwB0-61b4QM4MYfrs6w&s',
        'description': 'Collaborate and share ideas for the future.'
      },
      {
        'name': 'The Investment Circle',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJGPy-TIzdFCL6-dtBkDWqwewiwEavZO4bqQ&s',
        'description': 'Discuss investment opportunities and market trends.'
      },
      {
        'name': 'Bookworms Club',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'Share and discover books worth reading.'
      },
      {
        'name': 'Code Crackers',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'Swap and share cheat codes for your favorite games.'
      },
      {
        'name': 'Explore Kenya',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'Discover must-visit locations across Kenya.'
      },
      {
        'name': 'The Coding Hive',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'For those passionate about coding and development.'
      },
      {
        'name': 'Autonomous Era',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s',
        'description': 'Discuss the future of autonomous vehicles.'
      },
    ];
  }

  @override
  List<Map<String, dynamic>> getSocialNames() {
    return [
      {'name': 'Facebook', 'iconPath': 'assets/icons/facebook.svg'},
      {'name': 'Telegram', 'iconPath': 'assets/icons/telegram.svg'},
      {'name': 'Instagram', 'iconPath': 'assets/icons/instagram.svg'},
      {
        'name': 'Whatsapp',
        'iconPath': 'assets/icons/whatsapp.svg',
      },
      {
        'name': 'Snapchat',
        'iconPath': 'assets/icons/snapchat.svg',
      },
      {
        'name': 'LinkedIn',
        'iconPath': 'assets/icons/linkedIn.svg',
      },
      {
        'name': 'Reddit',
        'iconPath': 'assets/icons/reddit.svg',
      },
      {
        'name': 'Signal',
        'iconPath': 'assets/icons/signal.svg',
      },
      {
        'name': 'Vk',
        'iconPath': 'assets/icons/vk.svg',
      },
      {
        'name': 'Quora',
        'iconPath': 'assets/icons/quora.svg',
      },
      {
        'name': 'Discord',
        'iconPath': 'assets/icons/discord.svg',
      },
      {
        'name': 'Tumblr',
        'iconPath': 'assets/icons/tumblr.svg',
      },
      {
        'name': 'We-chat',
        'iconPath': 'assets/icons/wechat.svg',
      },
      {
        'name': 'X',
        'iconPath': 'assets/icons/x.svg',
      },
    ];
  }

  @override
  List<Map<String, dynamic>> getCategoryItems() {
    return [
      {
        'name': 'Entertainment',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6RjDa1u9ezwN12QFfACkuaSDVCzR0c5BWOQ&s'
      },
      {
        'name': 'Business',
        'imageUrl':
            'https://cloudinary.hbs.edu/hbsit/image/upload/s--Fm3oHP0m--/f_auto,c_fill,h_375,w_750,/v20200101/79015AB87FD6D3284472876E1ACC3428.jpg'
      },
      {
        'name': 'Music',
        'imageUrl':
            'https://i.pinimg.com/736x/c7/e4/b1/c7e4b153c32bf9b6eba97dce0b01f2b7.jpg'
      },
      {
        'name': 'Gaming',
        'imageUrl':
            'https://i.ytimg.com/vi/EA0YC9m6D4s/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCPEDlv0VGPIr2CC_juaUkgVRDJDQ'
      },
      {
        'name': 'Friendship',
        'imageUrl':
            'https://thesun.my/binrepository/2_3339706_20230728112908.jpg'
      },
      {
        'name': 'Comedy',
        'imageUrl':
            'https://www.pta.co.uk/pta/media/693-13-PTA_AUT22_Comedy-night.jpg'
      },
      {
        'name': 'Sports',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhq-RwOINUdWrp3jVGz3S9zb6pehan9kOBtg&s'
      },
      {
        'name': 'Technology',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7VLr3gZSqlfnybmCa1MXiBacZWB_qbIkJCg&s'
      },
      {
        'name': 'Education',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvABdDOpcooFFpqADJvIOx4LXyVEqXekCTWA&s'
      },
      {
        'name': 'Art',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQiN6wj1RZGPXrRmSGmc3y4lCRDE9o3iaNJnQ&s'
      },
      {
        'name': 'Health',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3Rh9HC9FtYJCzzjfUL_u4g6yBSnp38U7Fog&s'
      },
      {
        'name': 'Travel',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOCdAu2-R6Huawx5SJxvB55iZHY6FLqpjSDw&s'
      },
      {
        'name': 'Fashion',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdhkxRq140Y9d_s2UEJrwO4O1BheC6UWIzfg&s'
      },
      {
        'name': 'Food & Drink',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpr-OizYZSkpCqcI1SwB0-61b4QM4MYfrs6w&s'
      },
      {
        'name': 'Politics',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJGPy-TIzdFCL6-dtBkDWqwewiwEavZO4bqQ&s'
      },
      {
        'name': 'Books',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6rrRb0pd-FbCDnz-5IAjBCZjmYjrFRVmKFA&s'
      }
    ];
  }

  @override
  List<Map<String, dynamic>> getDummyNotifications() {
    return [
      {
        "title": "Bliitz team",
        "subtitle":
            "Special Offer Just for You! 🎉 We're giving you an exclusive 20% discount on your next purchase. Use code ‘THANKYOU’ at checkout to claim your reward before it expires!"
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Reminder: Your Wishlist is Waiting! 🛒 The items you loved are still available, but they won’t last forever. Grab them now before someone else does!"
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Exciting News! 🌟 A brand-new collection has just dropped. Be the first to explore the latest trends and elevate your style today."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Your Package is Almost Here! 🚚 Your order has been shipped and is scheduled for delivery tomorrow. Make sure someone is home to receive it!"
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Last Call for Discounts! ⏳ Today is the final day to enjoy up to 40% off sitewide. Don’t let these savings slip through your fingers!"
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Upgrade Your Experience! ✨ New features are now available in your app. Update now and enjoy faster performance and exclusive perks."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "You’ve Been Rewarded! 🎁 Check your account for a special loyalty bonus we’ve added just for you. Use it before it expires next week!"
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Your Subscription is About to End! ⚠️ Renew today to keep enjoying all your favorite features without any interruptions."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Stay Inspired! 💡 Check out our blog for the latest tips, tricks, and tutorials to help you achieve your goals."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Don’t Forget Your Appointment! 📅 You have a scheduled session tomorrow at 2:00 PM. Tap here to confirm or reschedule."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Congratulations! 🎉 You’ve unlocked a new level of rewards. Log in to explore your exclusive benefits and gifts."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Your Favorite Item is Back in Stock! 😍 Don’t miss out this time—add it to your cart and check out now before it’s gone again."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "It’s Time to Celebrate! 🎊 We’re turning five, and you’re invited to the party! Join us for special discounts and fun surprises all week long."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "You’re Almost There! 🚀 Complete your profile to unlock personalized recommendations and exclusive offers tailored just for you."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Keep Up the Great Work! 💪 Your progress is impressive—don’t stop now! Track your milestones and keep reaching for your goals."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Weekly Digest: What’s New? 📰 Catch up on the latest updates, features, and community highlights in our newsletter."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "A Gift Just for You! 🎁 We’ve added a surprise to your account. Use it today to make your next purchase even sweeter."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Ready for a Challenge? 🎯 Join our latest competition for a chance to win exciting prizes and showcase your skills."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Something Big is Coming! 🌟 Get ready for a major announcement tomorrow. Stay tuned—you won’t want to miss this."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Flash Sale Alert! ⚡ Enjoy up to 70% off for the next 24 hours only. Stock is limited, so hurry and shop now!"
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Welcome to the Community! 🥳 We’re thrilled to have you here. Check out our getting-started guide to make the most of your experience."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Heads Up: Scheduled Maintenance! ⚠️ Our platform will be down for maintenance on Saturday from 1:00 AM to 3:00 AM. Thank you for your understanding."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Your Order is Confirmed! 🛍️ Thank you for shopping with us. We’ll notify you as soon as your items are shipped."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Feeling Lucky? 🍀 Spin the wheel today for a chance to win amazing discounts and prizes. Try your luck now!"
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Trending Now: Limited Stock! 🚨 Don’t miss out on these popular picks. Shop before they’re gone forever!"
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Your Feedback Matters! 🗣️ Tell us what you think and help us improve. Complete this quick survey and earn a special reward."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "It’s Time for an Upgrade! 🆙 Your device is eligible for the latest version of our software. Download now for improved features and performance."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Your Friends Miss You! 💌 It’s been a while since your last visit. Come back today and enjoy a special welcome-back gift."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "Today’s Deal: Just for You! 🎯 Check out our exclusive daily offers and treat yourself to something special."
      },
      {
        "title": "Bliitz team",
        "subtitle":
            "You're in the Spotlight! 🌟 We’ve featured your content in our latest community highlights. Log in to see the buzz you’ve created!"
      },
    ];
  }

  @override
  List<String> getAccountList() {
    return [
      'Privacy Policy',
      'Terms of Service',
      'About Us',
      'Log Out',
      'Delete Account'
    ];
  }

  @override
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  @override
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (value.length < 8) return 'Password requires At least 8 characters';
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password requires at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password requires at least one number';
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return 'Password requires at least one special character (!@#\$&*~)';
    }
    return null;
  }

  @override
  Future<bool> requestGalleryAndCameraPermission() async {
    PermissionStatus photoStatus = await Permission.storage.request();
    PermissionStatus cameraStatus = await Permission.camera.request();
    if (photoStatus.isGranted && cameraStatus.isGranted) {
      return true;
    } else if (photoStatus.isPermanentlyDenied ||
        cameraStatus.isPermanentlyDenied) {
      await openAppSettings(); // opens system settings
      return false;
    } else {
      return false;
    }
  }

  @override
  bool isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasAbsolutePath &&
        (uri.isScheme("http") || uri.isScheme("https"));
  }

  @override
  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication); // Opens in app if possible
    } else {
      debugPrint("❌ Could not launch $url");
    }
  }

  @override
  Future<List<String>> getFavoriteLinks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  @override
  Future<void> addFavorite(String linkId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    if (!favorites.contains(linkId)) {
      favorites.add(linkId);

      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  @override
  Future<bool> isFavorite(String linkId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    return favorites.contains(linkId);
  }

  @override
  Future<void> removeFavorite(String linkId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    favorites.remove(linkId);

    await prefs.setStringList(_favoritesKey, favorites);
  }

  //

  @override
  Future<List<String>> getLikedLinks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_likedKey) ?? [];
  }

  @override
  Future<void> addLikedLinks(String linkId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedlinks = prefs.getStringList(_likedKey) ?? [];

    if (!likedlinks.contains(linkId)) {
      likedlinks.add(linkId);

      await prefs.setStringList(_likedKey, likedlinks);
    }
  }

  @override
  Future<bool> isLikedLink(String linkId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedlinks = prefs.getStringList(_likedKey) ?? [];

    return likedlinks.contains(linkId);
  }

  @override
  Future<void> removeLikedLink(String linkId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedlinks = prefs.getStringList(_likedKey) ?? [];

    likedlinks.remove(linkId);

    await prefs.setStringList(_likedKey, likedlinks);
  }

  //

  @override
  Future<List<String>> getDisLikedLinks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_dislikedKey) ?? [];
  }

  @override
  Future<void> addDisLikedLinks(String linkId) async {
    final prefs = await SharedPreferences.getInstance();
    final dislikedlinks = prefs.getStringList(_dislikedKey) ?? [];

    if (!dislikedlinks.contains(linkId)) {
      dislikedlinks.add(linkId);

      await prefs.setStringList(_dislikedKey, dislikedlinks);
    }
  }

  @override
  Future<bool> isDisLikedLink(String linkId) async {
    final prefs = await SharedPreferences.getInstance();
    final dislikedlinks = prefs.getStringList(_dislikedKey) ?? [];

    return dislikedlinks.contains(linkId);
  }

  @override
  Future<void> removeDisLikedLink(String linkId) async {
    final prefs = await SharedPreferences.getInstance();
    final dislikedlinks = prefs.getStringList(_dislikedKey) ?? [];

    dislikedlinks.remove(linkId);

    await prefs.setStringList(_dislikedKey, dislikedlinks);
  }

  @override
  Future<void> saveRecentSearches({
    required Map<String, dynamic> groupDetails,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existingData = prefs.getStringList('searched_links') ?? [];

    final alreadyExists = existingData.any((item) {
      final parsed = jsonDecode(item);
      return parsed['id'] == groupDetails['id'];
    });

    if (!alreadyExists) {
      final newLink = {
        'id': groupDetails['id'],
        'Social': groupDetails['Social'],
        'Name': groupDetails['Name'],
        'Description': groupDetails['Description'],
        'Link': groupDetails['Link'],
        'Link Type': groupDetails['Link Type'],
        'Category': groupDetails['Category'],
        'Profile Image': groupDetails['Profile Image'],
        // 'createdAt': groupDetails['createdAt'],
        'createdBy': groupDetails['createdBy'],
        'favourites': groupDetails['favourites'],
        'likes': groupDetails['likes'],
        'dislikes': groupDetails['dislikes'],
        'rankingScore': groupDetails['rankingScore'],
      };

      existingData.add(jsonEncode(newLink));
      await prefs.setStringList('searched_links', existingData);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSearchedLinks() async {
    final prefs = await SharedPreferences.getInstance();

    final storedList = prefs.getStringList('searched_links') ?? [];

    // Decode each JSON string to a Map<String, String>
    final links = storedList.map((item) {
      final decoded = jsonDecode(item);
      return Map<String, dynamic>.from(decoded);
    }).toList();

    return links;
  }

  @override
  Future<void> saveSearchSuggestions({
    required Map<String, dynamic> groupDetails,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existingData = prefs.getStringList('search_suggestions') ?? [];

    final alreadyExists = existingData.any((item) {
      final parsed = jsonDecode(item);
      return parsed['id'] == groupDetails['id'];
    });

    if (!alreadyExists) {
      final newLink = {
        'id': groupDetails['id'],
        'Social': groupDetails['Social'],
        'Name': groupDetails['Name'],
        'Description': groupDetails['Description'],
        'Link': groupDetails['Link'],
        'Link Type': groupDetails['Link Type'],
        'Category': groupDetails['Category'],
        'Profile Image': groupDetails['Profile Image'],
        // 'createdAt': groupDetails['createdAt'] as String,
        'createdBy': groupDetails['createdBy'],
        'favourites': groupDetails['favourites'],
        'likes': groupDetails['likes'],
        'dislikes': groupDetails['dislikes'],
        'rankingScore': groupDetails['rankingScore'],
      };

      existingData.add(jsonEncode(newLink));
      await prefs.setStringList('search_suggestions', existingData);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSearchSuggestions() async {
    final prefs = await SharedPreferences.getInstance();

    final storedList = prefs.getStringList('search_suggestions') ?? [];
    // Decode each JSON string to a Map<String, String>
    final links = storedList.map((item) {
      final decoded = jsonDecode(item);
      return Map<String, dynamic>.from(decoded);
    }).toList();

    return links;
  }

  @override
  Future<void> deletedSearchSuggestion() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('search_suggestions', []);
  }

  @override
  Future<void> persistCategoryCountsLocally() async {
    final firestore = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();

    // Step 1: Fetch all category documents from Firestore
    final snapshot = await firestore.collection('Categories').get();

    // Step 2: Map them into a list of Map<String, dynamic>
    final categories = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "name": data['name'], // Using document ID as category name
        "linkCount": data['linkCount'] ?? 0,
        "imageUrl": data['imageUrl'] ?? "",
      };
    }).toList();

    // Step 3: Encode the list into JSON strings
    final categoryJsonList = categories.map((cat) => json.encode(cat)).toList();

    // Step 4: Store in SharedPreferences
    await prefs.setStringList('category_counts', categoryJsonList);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLocalCategoryCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final categoryJsonList = prefs.getStringList('category_counts') ?? [];
    return categoryJsonList
        .map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<void> initiateForegroundNotifications(BuildContext context) async {
    void handleNotificationTapRoute(String payload) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationScreen()),
      );
    }

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    Future<void> onForegroundTapNotification(
      NotificationResponse notificationResponse,
    ) async {
      handleNotificationTapRoute(notificationResponse.payload!);
    }

    const android = AndroidInitializationSettings('logo');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onForegroundTapNotification,
    );

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;

      final backgroundPersistence = BackgroundPersistence();

      final backgroundNotification = BackgroundNotification(
        notificationId: '',
        title: message.notification!.title,
        message: message.notification!.body,
        isread: 'no',
      );
      await backgroundPersistence.insertMessage(backgroundNotification);

      final longdata = notification?.body ?? '';
      final bigTextStyleInformation = BigTextStyleInformation(longdata);
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigTextStyleInformation,
      );
      const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      if (notification != null) {
        final payloadMap = <String, dynamic>{
          'title': notification.title,
          'body': notification.body,
        };
        final jsonString = jsonEncode(payloadMap);
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          platformChannelSpecifics,
          payload: jsonString,
        );

        // context
        //     .read<GetBackgroundNotificationsCubit>()
        //     .getBackgroundNotifications();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payloadMap = <String, dynamic>{
        'title': message.notification!.title,
        'body': message.notification!.body,
      };

      final jsonString = jsonEncode(payloadMap);
      handleNotificationTapRoute(jsonString);
    });
  }

  @override
  Future<void> handleTerminatedNotificationTap(BuildContext context) async {
    void handleNotificationTapRoute(String payload) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationScreen()),
      );
    }

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final payloadMap = <String, dynamic>{
        'title': initialMessage.notification!.title,
        'body': initialMessage.notification!.body,
      };

      final jsonString = jsonEncode(payloadMap);
      handleNotificationTapRoute(jsonString);
    }
  }

  @override
  Future<void> trackLinkImpression(
      {required String linkId, required String linkCreatorId}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final cacheKey = '$userId-$linkId-$today';

    if (prefs.getBool(cacheKey) == true) return;

    // Mark as seen today
    await prefs.setBool(cacheKey, true);

    // Write to Firestore
    await FirebaseFirestore.instance
        .collection('Links')
        .doc(linkId)
        .update({'totalImpressions': FieldValue.increment(1)});

    await FirebaseFirestore.instance.collection('Users').doc(linkCreatorId).set(
        {'totalImpressions': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  @override
  String resolvePlanTitle({required String planId}) {
    final parts = planId.split('_');
    if (parts.length != 2) return 'Unknown Plan';

    final type = parts[0]; // "upgrade" or "subscribe"
    final tier = parts[1]; // "minimal", "basic", etc.

    final tierName = {
          'minimal': 'Minimal',
          'basic': 'Basic',
          'essential': 'Essential',
          'premium': 'Premium',
        }[tier] ??
        'Unknown Plan';

    final suffix = {
          'upgrade': ' - One Time',
          'subscribe': ' - Subscription',
        }[type] ??
        '';

    return tierName + suffix;
  }
}
