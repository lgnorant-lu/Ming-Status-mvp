/*
---------------------------------------------------------------
File name:          workshop_en.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Workshop English translations - Phase 2.2 Sprint 2 distributed i18n system
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// Workshop English translation provider
class WorkshopEnProvider extends BasePackageI18nProvider {
  WorkshopEnProvider() : super('workshop_en') {
    addTranslations(SupportedLocale.english, _enTranslations);
  }

  static const Map<String, String> _enTranslations = {
    // Module title
    'workshop_title': 'Workshop',
    'module_name': 'Workshop',
    'module_description': 'Record your creativity and inspiration',
    
    // Basic operations
    'initializing': 'Initializing Workshop...',
    'no_creative_projects': 'No creative projects',
    'create_new_creative_project': 'Create New Creative Project',
    'new_creative_idea': 'New Creative Idea',
    'new_creative_description': 'Describe creative idea',
    'detailed_creative_content': 'Detailed creative content',
    'creative_project_created': 'Creative project created',
    'creative_project_deleted': 'Creative project deleted',
    
    // UI elements
    'add_project': 'Add Project',
    'project_list': 'Project List',
    'project_details': 'Project Details',
    'edit_project': 'Edit Project',
    'delete_project': 'Delete Project',
    'save_project': 'Save Project',
    'cancel': 'Cancel',
    'edit': 'Edit',
    'delete': 'Delete',
    
    // Edit and update
    'creative_project_updated': 'Creative project updated',
    'edit_creative_project': 'Edit Creative Project',
    
    // Status
    'draft': 'Draft',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'archived': 'Archived',
    
    // Operation confirmations
    'confirm_delete': 'Confirm Delete',
    'delete_project_message': 'Are you sure you want to delete this creative project? This action cannot be undone.',
    'yes': 'Yes',
    'no': 'No',
    
    // Form fields
    'project_title': 'Project Title',
    'project_description': 'Project Description',
    'project_content': 'Project Content',
    'project_tags': 'Project Tags',
    'created_date': 'Created Date',
    'updated_date': 'Updated Date',
    
    // Error messages
    'title_required': 'Title is required',
    'description_required': 'Description is required',
    'save_failed': 'Save failed',
    'delete_failed': 'Delete failed',
    'load_failed': 'Load failed',
  };
} 