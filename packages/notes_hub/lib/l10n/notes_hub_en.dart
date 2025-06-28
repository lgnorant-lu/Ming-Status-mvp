/*
---------------------------------------------------------------
File name:          notes_hub_en.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Notes Hub English translations - Phase 2.2 Sprint 2 distributed i18n system
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// Notes Hub English translation provider
class NotesHubEnProvider extends BasePackageI18nProvider {
  NotesHubEnProvider() : super('notes_hub_en') {
    addTranslations(SupportedLocale.english, _enTranslations);
  }

  static const Map<String, String> _enTranslations = {
    // Module title
    'notes_hub_title': 'Notes Hub',
    'module_name': 'Notes Hub',
    'module_description': 'Manage your notes and tasks',
    
    // Basic operations
    'search_hint': 'Search tasks...',
    'initializing': 'Initializing task management center...',
    'create_new': 'Create',
    'edit': 'Edit',
    'delete': 'Delete',
    'save': 'Save',
    'cancel': 'Cancel',
    'close': 'Close',
    
    // Item types
    'note': 'Note',
    'todo': 'Task',
    'project': 'Project',
    'reminder': 'Reminder',
    'habit': 'Habit',
    'goal': 'Goal',
    'all_types': 'All Types',
    
    // Status
    'total': 'Total',
    'active': 'Active',
    'completed': 'Completed',
    'archived': 'Archived',
    
    // Priority
    'priority': 'Priority',
    'priority_urgent': 'Urgent',
    'priority_high': 'High',
    'priority_medium': 'Medium',
    'priority_low': 'Low',
    
    // Fields
    'title': 'Title',
    'content': 'Content',
    'status': 'Status',
    'created_at': 'Created At',
    'updated_at': 'Updated At',
    'due_date': 'Due Date',
    'tags': 'Tags',
    
    // Create and edit
    'create_new_item': 'Create new {itemType}',
    'edit_item': 'Edit {itemType}',
    'item_created': 'Created new {itemType}',
    'item_updated': 'Updated {itemType}',
    'item_deleted': 'Deleted {itemType}',
    
    // Empty state
    'no_items_found': 'No {itemType} found',
    'create_item_hint': 'Tap + button to create {itemType}',
    
    // Confirmation dialogs
    'confirm_delete': 'Confirm Delete',
    'confirm_delete_message': 'Are you sure you want to delete "{itemName}"? This action cannot be undone.',
    
    // Error and success messages
    'create_failed': 'Create Failed',
    'update_failed': 'Update Failed',
    'delete_failed': 'Delete Failed',
    'item_not_found': 'Item Not Found',
    'operation_success': 'Operation Success',
    'item_updated_success': '{itemType} updated successfully',
    'edit_failed_item_not_found': 'Edit failed: item not found',
    
    // Time formatting
    'today': 'Today',
    'yesterday': 'Yesterday',
    'days_ago': '{days} days ago',
    
    // Interface elements
    'welcome_title': 'Welcome to Notes Hub',
    'welcome_description': 'This is your personal task management center, supporting notes, tasks, projects and other types of task management.',
    'active_badge': 'Active',
    'new_item_button': 'New Note',
  };
} 