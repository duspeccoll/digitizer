# About This Plugin

Digitizer is an (inaptly-named) [ArchivesSpace](https://archivesspace.org) plugin that allows a user to create Digital Object records for digital representations of an Archival Object (e.g. a component of a larger archival collection). It is functionally the same as our former [item_linker](https://github.com/duspeccoll/item_linker) plugin, only it does most of its work in the ArchivesSpace backend application, which allows us to more efficiently create digital object records in a batch via the command line.

It may be accessed via the ArchivesSpace staff interface via the "More" drop-down menu in the component toolbar; look for the "Create Digital Object" option. (Note that this option is only available for item records at this time, in line with our implementation of ArchivesSpace at the University of Denver.)

# Future Enhancements

* From the backend, allow a user to specify the digital_object_id they wish to provide (instead of checking for handles or component IDs as it does now)
* Clean up permissions

# In Conclusion

This plugin is maintained by Kevin Clair at the University of Denver; e-mail him with questions or comments -- kevin dot clair at du dot edu.
