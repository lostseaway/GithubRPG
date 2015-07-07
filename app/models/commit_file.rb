class CommitFile < ActiveRecord::Base
	def self.addFile(commit_id,file)
		ft = FileType.find_by(name: file["file_type_id"])
		if ft == nil
			ft = FileType.create(name: file["file_type_id"])
		end
		file["file_type_id"] = ft.id
		create(file)
	end
end
