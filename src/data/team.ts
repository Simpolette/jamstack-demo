export interface TeamMember {
  id: string;
  name: string;
  role: string;
  topic: string;
  avatar: string;
  bio: string;
  skills: string[];
  github: string;
  focusArea: string;
  color: string;
}

export const teamMembers: TeamMember[] = [
  {
    id: "an-1",
    name: "Nguyễn Văn An",
    role: "Microservices Architect & Lead",
    topic: "Microservices Architecture",
    avatar: "https://api.dicebear.com/7.x/bottts/svg?seed=An1",
    bio: "Chuyên gia về kiến trúc Microservices, Kubernetes deployment, Service Mesh (Istio) và hệ thống quan sát Observability (Prometheus + Grafana).",
    skills: ["Docker", "Kubernetes", "Istio", "Prometheus", "Grafana", "Go"],
    github: "an-nguyen-dev",
    focusArea: "Scalability & Resilience cho hệ thống Microservices",
    color: "from-blue-500 to-indigo-600"
  },
  {
    id: "an-2",
    name: "Trần Thị An",
    role: "Micro-Frontends & UI Engineer",
    topic: "Micro-Frontends & Modular UI",
    avatar: "https://api.dicebear.com/7.x/bottts/svg?seed=An2",
    bio: "Đam mê xây dựng các giao diện mở rộng linh hoạt theo kiến trúc Micro-Frontends, Module Federation và quản lý cấu trúc thư mục phát triển hệ thống lớn.",
    skills: ["React", "Module Federation", "TypeScript", "TailwindCSS", "Webpack", "Nginx"],
    github: "an-tran-ui",
    focusArea: "UI Composition & Inter-module Communication",
    color: "from-purple-500 to-pink-600"
  },
  {
    id: "giang",
    name: "Lê Hoài Giang",
    role: "JAMstack & Cloud Native Developer",
    topic: "JAMstack & Edge Computing",
    avatar: "https://api.dicebear.com/7.x/bottts/svg?seed=Giang",
    bio: "Tập trung nghiên cứu hiệu năng web tĩnh JAMstack với Astro, tích hợp Serverless API, Vector Databases và kiến trúc Retrieval-Augmented Generation.",
    skills: ["Astro", "GitHub Actions", "CDN / Edge", "Vector DB", "TypeScript", "Python"],
    github: "yuran1811",
    focusArea: "Pre-rendering SSG & Serverless API Integration",
    color: "from-emerald-500 to-teal-600"
  },
  {
    id: "khoa-1",
    name: "Phạm Minh Khoa",
    role: "LLM Agent & AI Engineer",
    topic: "LLM Agent Architectures",
    avatar: "https://api.dicebear.com/7.x/bottts/svg?seed=Khoa1",
    bio: "Xây dựng các Agent thông minh dựa trên LLM với khả năng tự lập kế hoạch (Planning), gọi Tools/APIs và ghi nhớ bộ nhớ ngắn/dài hạn (Memory).",
    skills: ["LangChain", "LlamaIndex", "OpenAI API", "Python", "FastAPI", "Docker"],
    github: "khoa-pham-ai",
    focusArea: "Autonomous Planning & Tool Calling Integration",
    color: "from-amber-500 to-orange-600"
  },
  {
    id: "khoa-2",
    name: "Hoàng Đăng Khoa",
    role: "Data & Event Sourcing Specialist",
    topic: "Event Sourcing & Analytics",
    avatar: "https://api.dicebear.com/7.x/bottts/svg?seed=Khoa2",
    bio: "Chuyên môn sâu về cơ chế Rebuild State từ Event Log, xử lý dữ liệu luồng lớn (Stream Processing) và các mẫu kiến trúc dữ liệu Lambda / Kappa.",
    skills: ["EventStoreDB", "Apache Spark", "Ray", "Kafka", "PostgreSQL", "Java"],
    github: "khoa-hoang-data",
    focusArea: "State Reconstruction & Stream Processing Patterns",
    color: "from-cyan-500 to-blue-600"
  },
  {
    id: "tan",
    name: "Đỗ Nhật Tấn",
    role: "Event-Driven Architecture Expert",
    topic: "Event-Driven Systems",
    avatar: "https://api.dicebear.com/7.x/bottts/svg?seed=Tan",
    bio: "Thiết kế các hệ thống hướng sự kiện bất đồng bộ với RabbitMQ/Kafka, đảm bảo kiểm tra tính hợp lệ dữ liệu đầu vào và giám sát sự kiện toàn hệ thống.",
    skills: ["RabbitMQ", "Apache Kafka", "OpenTelemetry", "Distributed Tracing", "Node.js"],
    github: "tan-do-event",
    focusArea: "Asynchronous Messaging & Distributed Observability",
    color: "from-rose-500 to-red-600"
  }
];
