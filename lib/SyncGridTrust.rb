require "java"

include_class "gov.nih.nci.cagrid.syncgts.bean.SyncDescription"
include_class "gov.nih.nci.cagrid.syncgts.core.SyncGTS"
include_class "gov.nih.nci.cagrid.common.Utils"

class SyncGridTrust
  def self.synchronizeOnce(syncDescriptionFile)
    success = false
    begin
      pathToSyncDescription = syncDescriptionFile
      description = Utils.deserializeDocument(Rails.root.to_s + pathToSyncDescription, SyncDescription)
      SyncGTS.getInstance().syncOnce(description)
      success = true
    rescue
      puts "Error: " + $!
    end
    return success
  end

end