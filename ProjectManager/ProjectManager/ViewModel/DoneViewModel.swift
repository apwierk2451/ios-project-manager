//
//  DoneViewModel.swift
//  ProjectManager
//
//  Created by bonf on 2022/09/19.
//

import RxSwift

final class DoneViewModel: ViewModelType {
    
    // MARK: - properties
    
    let provider = TodoProvider.shared
    
    var projectList = BehaviorSubject<[Project]>(value: [])
    let disposeBag = DisposeBag()
    
    init() {
        let projects = provider.testProjects.filter { $0.status == .done }
        self.projectList.onNext(projects)
    }
    
    func transform(_ input: DoneViewInput) -> DoneViewOutput {
        input.updateAction
            .bind(onNext: { [weak self] project in
                self?.provider.updateData(project: project)
                self?.resetProjectList(status: .done)
            })
            .disposed(by: disposeBag)
        
        input.changeStatusAction
            .bind(onNext: { [weak self] (id, status) in
                guard var selectedProject = self?.selectProject(id: id) else { return }
                selectedProject.status = status
                self?.provider.updateData(project: selectedProject)
                self?.resetProjectList(status: .done)
            })
            .disposed(by: disposeBag)
        
        return DoneViewOutput(doneList: projectList)
    }
}

struct DoneViewInput {
    let updateAction: Observable<Project>
    let changeStatusAction: Observable<(UUID, Status)>
}

struct DoneViewOutput {
    var doneList: Observable<[Project]>
}
