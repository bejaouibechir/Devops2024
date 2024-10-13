# Déclenchement Manuel


Ce job peut être **déclenché manuellement** via l’interface GitLab, ce qui est utile pour des tests ponctuels.

stages:
  - test

test_on_manual_trigger:
  stage: test
  script:
    - echo "Running manually triggered tests"
    - npm install
    - npm test
  when: manual
