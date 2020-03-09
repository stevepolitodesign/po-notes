class NotePolicy < ApplicationPolicy
  def show?
    record.user == user || record.public
  end
  
  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  def versions?
    record.user == user
  end

  def version?
    record.user == user
  end 

  def revert?
    record.user == user
  end

  def restore?
    record.user == user
  end  
end