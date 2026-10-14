# Drug Knowledge Graph from Drugs.com (EDC, 2026-10-14)

Drugs.com에서 미국 처방량 상위 50개 약의 페이지를 크롤링하고, EDC(Extract–Define–Canonicalize)를 약물 도메인에 맞게 적용해 만든 지식그래프입니다.

| 항목 | 값 |
|---|---|
| 대상 | ClinCalc DrugStats 처방량 상위 50개 약 중 Drugs.com 페이지가 있는 50개 |
| 입력 | 약별 메인 페이지 50개 → 섹션 기반 청크 854개 |
| 방법 | EDC + 도메인 적응 (시드 관계 40개, 약 이름·섹션 컨텍스트 프롬프트, 약물 few-shot) |
| LLM / 임베딩 | Qwen3-14B-AWQ (vLLM) / BAAI/bge-base-en-v1.5 |
| **트리플** | **12,233** (EDC 추출 11,352 + 페이지 메타데이터 969, 88개 중복) |
| 엔티티 | 7,529 (22개 타입) |
| 관계 | 149 (시드 40 + 정규화 중 추가된 관계 109) |

## 폴더 구조

```
04_261014_DrugKG/
├── 04_261014_DrugKG.html     대화형 KG 탐색기 (브라우저로 열기)
├── kg/                       지식그래프
│   ├── triples.csv           트리플 12,233개 (메인 파일)
│   ├── triples.jsonl         트리플 + 출처(약, 섹션, chunk_id, 정규화 전 관계명, URL)
│   ├── entities.csv          엔티티 id, label, type, mentions
│   ├── schema.csv            관계 149개의 정의, subject/object 타입, seed/enriched, 트리플 수
│   ├── chunks.jsonl          출처 chunk_id의 원문 텍스트
│   ├── kg.ttl                RDF Turtle
│   ├── kg.graphml            GraphML (networkx, Gephi)
│   ├── neo4j/                Neo4j 적재용 nodes.csv, relationships.csv, import.cypher
│   └── stats.json            통계 요약
└── crawling/                 크롤링 데이터
    ├── drug_list/            top50.yaml (대상 약 목록), drug_urls.json (약 → Drugs.com URL)
    ├── raw_html/             Drugs.com 원본 HTML 50개
    ├── parsed/               HTML 파싱 결과 (메타데이터 + 섹션별 텍스트) 50개
    └── text/                 섹션 구조 텍스트 50개 (EDC 입력)
```

## triples.csv 열

| 열 | 내용 |
|---|---|
| subject, relation, object | 트리플 |
| subject_type, object_type | 엔티티 타입 (Drug, Condition, SideEffect, Instruction 등 22종) |
| count | 같은 트리플이 추출된 횟수 |
| drugs | 트리플이 나온 페이지의 약 (slug) |
| sources | `edc` = 본문에서 LLM 추출, `structured` = 페이지 정보 상자(브랜드명, 약물 분류, 제형·함량, 관련 약, 처방 구분) |
| relation_origin | `seed` = 미리 정의한 40개 관계, `enriched` = 정규화 중 새로 추가된 관계 |

## KG 탐색기 (04_261014_DrugKG.html)

같은 KG(트리플 12,233개)를 담은 단일 HTML 파일입니다. 브라우저로 열면 다음을 할 수 있습니다.
- 엔티티 검색 후 1~2 hop 이웃 그래프 보기, 관계·엔티티 타입·등장 횟수 필터
- 50개 약 개요 그래프, 여러 약이 공유하는 부작용 보기
- 엣지를 클릭하면 근거 원문 청크와 정규화 전 관계명 표시, 현재 화면을 CSV로 내보내기

그래프 라이브러리(vis-network)를 CDN에서 불러오므로 인터넷 연결이 필요합니다. GitHub 저장소 화면에서는 HTML이 실행되지 않으니 내려받아 열거나 GitHub Pages로 보세요.

## 참고

- 크롤링 데이터는 Drugs.com 소비자용 약 정보 페이지이며, 수업 과제용 비상업적 목적으로 요청 간격을 두고 수집했습니다. 원문 저작권은 Drugs.com에 있습니다.
- `triples.jsonl`의 provenance에는 트리플마다 첫 번째 출처 하나가 들어 있습니다.
