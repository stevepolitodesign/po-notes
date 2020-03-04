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
end